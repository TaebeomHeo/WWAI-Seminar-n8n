# 고급: 실전 AI 활용 및 데이터 수집

실제 서비스에서 데이터를 수집하고 AI로 처리하는 고급 워크플로우를 배웁니다.

---

## 📧 Gmail에서 고객 문의 수집 및 AI 분석

### 전체 워크플로우

```
Gmail Trigger (새 이메일 수신)
    ↓
이메일 데이터 정제
    ↓
OpenAI - 감정 분석
    ↓
OpenAI - 카테고리 분류
    ↓
우선순위 계산
    ↓
OpenAI - 자동 응답 생성
    ↓
IF (긴급 문의?)
    ├─ Yes → Slack 알림 + 담당자 할당
    └─ No → Google Sheets 저장 + 자동 응답 전송
```

### 1단계: Gmail Trigger 설정

```javascript
// Gmail Trigger 노드 설정
{
  "event": "message.received",
  "filters": {
    "labelIds": ["INBOX"],
    "q": "to:support@company.com -from:noreply"  // 자동 메일 제외
  }
}
```

### 2단계: 이메일 데이터 추출

```javascript
// Code 노드
const email = $json;

// 헤더에서 정보 추출
const getHeader = (headers, name) => {
  const header = headers.find(h => h.name.toLowerCase() === name.toLowerCase());
  return header ? header.value : '';
};

const headers = email.payload.headers;

// 본문 추출 (HTML 또는 Plain Text)
let emailBody = '';
if (email.payload.parts) {
  const textPart = email.payload.parts.find(part => part.mimeType === 'text/plain');
  const htmlPart = email.payload.parts.find(part => part.mimeType === 'text/html');

  if (textPart && textPart.body.data) {
    emailBody = Buffer.from(textPart.body.data, 'base64').toString('utf-8');
  } else if (htmlPart && htmlPart.body.data) {
    const html = Buffer.from(htmlPart.body.data, 'base64').toString('utf-8');
    // HTML 태그 제거 (간단한 방법)
    emailBody = html.replace(/<[^>]*>/g, '').trim();
  }
} else if (email.payload.body.data) {
  emailBody = Buffer.from(email.payload.body.data, 'base64').toString('utf-8');
}

return {
  id: email.id,
  threadId: email.threadId,
  from: getHeader(headers, 'From'),
  to: getHeader(headers, 'To'),
  subject: getHeader(headers, 'Subject'),
  date: getHeader(headers, 'Date'),
  body: emailBody,
  snippet: email.snippet,
  labels: email.labelIds || [],
  received_at: new Date().toISOString()
};
```

### 3단계: OpenAI 감정 분석 (JSON 모드 활용)

```javascript
// OpenAI 노드 설정
{
  "model": "gpt-3.5-turbo-1106",  // JSON 모드 지원
  "messages": [
    {
      "role": "system",
      "content": `당신은 고객 서비스 전문가입니다.
이메일의 감정을 분석하여 JSON 형식으로 응답해주세요.

응답 형식:
{
  "sentiment": "긍정" | "부정" | "중립",
  "confidence": 0-100,
  "key_emotions": ["감정1", "감정2"],
  "urgency_level": "낮음" | "보통" | "높음" | "긴급",
  "customer_mood": "만족" | "불만" | "분노" | "혼란" | "중립"
}`
    },
    {
      "role": "user",
      "content": `제목: {{$json.subject}}\n내용: {{$json.body}}`
    }
  ],
  "response_format": { "type": "json_object" }
}

// Code 노드로 파싱
const response = JSON.parse($json.message.content);
return {
  ...$node["Email Data"].json,
  sentiment: response.sentiment,
  confidence: response.confidence,
  key_emotions: response.key_emotions,
  urgency_level: response.urgency_level,
  customer_mood: response.customer_mood
};
```

### 4단계: OpenAI 카테고리 분류 (Function Calling)

```javascript
// OpenAI 노드 - Function Calling 사용
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "고객 이메일을 적절한 카테고리로 분류하는 전문가입니다."
    },
    {
      "role": "user",
      "content": `제목: {{$json.subject}}\n내용: {{$json.body}}`
    }
  ],
  "functions": [
    {
      "name": "classify_email",
      "description": "고객 이메일을 카테고리로 분류합니다",
      "parameters": {
        "type": "object",
        "properties": {
          "category": {
            "type": "string",
            "enum": ["기술지원", "판매문의", "환불요청", "제품문의", "칭찬", "불만", "기타"],
            "description": "이메일의 주요 카테고리"
          },
          "subcategory": {
            "type": "string",
            "description": "세부 카테고리"
          },
          "confidence": {
            "type": "number",
            "description": "분류 신뢰도 (0-100)"
          },
          "suggested_department": {
            "type": "string",
            "enum": ["기술팀", "영업팀", "고객지원팀", "경영지원팀"],
            "description": "담당 부서"
          }
        },
        "required": ["category", "confidence", "suggested_department"]
      }
    }
  ],
  "function_call": { "name": "classify_email" }
}

// Code 노드로 Function 결과 파싱
const functionCall = $json.message.function_call;
const classification = JSON.parse(functionCall.arguments);

return {
  ...$input.first().json,
  category: classification.category,
  subcategory: classification.subcategory || "",
  classification_confidence: classification.confidence,
  suggested_department: classification.suggested_department
};
```

### 5단계: 복합 우선순위 계산 (AI + 규칙 기반)

```javascript
// Code 노드
const data = $json;

let priorityScore = 0;

// 1. 감정 기반 점수
const sentimentScores = {
  "부정": 3,
  "중립": 1,
  "긍정": 0
};
priorityScore += sentimentScores[data.sentiment] || 0;

// 2. 고객 감정 상태 기반
const moodScores = {
  "분노": 4,
  "불만": 3,
  "혼란": 2,
  "중립": 1,
  "만족": 0
};
priorityScore += moodScores[data.customer_mood] || 0;

// 3. 긴급도 수준
const urgencyScores = {
  "긴급": 4,
  "높음": 3,
  "보통": 1,
  "낮음": 0
};
priorityScore += urgencyScores[data.urgency_level] || 0;

// 4. 카테고리 기반
const categoryScores = {
  "환불요청": 3,
  "불만": 3,
  "기술지원": 2,
  "판매문의": 1,
  "제품문의": 1,
  "칭찬": 0
};
priorityScore += categoryScores[data.category] || 0;

// 5. 키워드 기반 (제목 + 본문)
const urgentKeywords = ["긴급", "빨리", "즉시", "오류", "문제", "안됨", "불가능", "환불", "해지"];
const text = (data.subject + " " + data.body).toLowerCase();
const urgentKeywordCount = urgentKeywords.filter(keyword => text.includes(keyword)).length;
priorityScore += urgentKeywordCount * 0.5;

// 6. 이메일 길이 (긴 이메일 = 복잡한 문제)
if (data.body.length > 500) priorityScore += 1;

// 7. VIP 고객 체크 (예: 도메인 기반)
const vipDomains = ["enterprise-customer.com", "vip-partner.com"];
const senderDomain = data.from.split('@')[1];
if (vipDomains.includes(senderDomain)) {
  priorityScore += 3;
}

// 최종 우선순위 결정
let priority = "낮음";
let sla_hours = 48;  // SLA 응답 시간

if (priorityScore >= 10) {
  priority = "긴급";
  sla_hours = 2;
} else if (priorityScore >= 7) {
  priority = "높음";
  sla_hours = 8;
} else if (priorityScore >= 4) {
  priority = "보통";
  sla_hours = 24;
}

return {
  ...data,
  priority_score: priorityScore,
  priority: priority,
  sla_hours: sla_hours,
  sla_deadline: new Date(Date.now() + sla_hours * 60 * 60 * 1000).toISOString()
};
```

### 6단계: OpenAI - 맞춤형 자동 응답 생성

```javascript
// OpenAI 노드
{
  "model": "gpt-4",  // 더 나은 품질의 응답을 위해 GPT-4 사용
  "messages": [
    {
      "role": "system",
      "content": `당신은 경험 많은 고객 서비스 담당자입니다.

답변 작성 가이드라인:
1. 고객의 감정을 이해하고 공감 표현
2. 문제에 대한 구체적인 해결책 또는 다음 단계 안내
3. 필요시 추가 정보 요청
4. 정중하고 전문적인 톤 유지
5. 고객 이름이 있으면 사용
6. 회사명: "우리 회사"
7. 서명: "고객지원팀 드림"

고객 정보:
- 감정: {{$json.sentiment}} ({{$json.customer_mood}})
- 카테고리: {{$json.category}}
- 우선순위: {{$json.priority}}
- SLA 기한: {{$json.sla_hours}}시간 이내

원본 이메일:
제목: {{$json.subject}}
내용: {{$json.body}}`
    },
    {
      "role": "user",
      "content": "위 고객 이메일에 대한 전문적이고 도움이 되는 답변을 작성해주세요."
    }
  ],
  "temperature": 0.7
}

// Code 노드로 응답 포맷팅
const autoResponse = $json.message.content;

return {
  ...$input.first().json,
  auto_response: autoResponse,
  response_generated_at: new Date().toISOString()
};
```

---

## 🤖 AI 품질 향상 기법

### 1. Few-Shot Learning (예제 제공)

```javascript
// System Message에 예제 포함
{
  "role": "system",
  "content": `고객 이메일을 분석합니다.

예제 1:
입력: "제품이 정말 훌륭합니다! 배송도 빨랐어요."
출력: {"sentiment": "긍정", "confidence": 95, "urgency": "낮음"}

예제 2:
입력: "제품이 고장났습니다. 긴급히 교체 부탁드립니다."
출력: {"sentiment": "부정", "confidence": 90, "urgency": "긴급"}

이제 다음 이메일을 분석해주세요:`
}
```

### 2. Chain of Thought (단계별 사고)

```javascript
{
  "role": "system",
  "content": `다음 단계로 이메일을 분석해주세요:

1. 고객이 무엇을 원하는지 파악
2. 감정 상태 분석
3. 문제의 긴급성 평가
4. 적절한 카테고리 결정
5. 최종 분류 결과 JSON 출력

각 단계의 사고 과정을 간단히 설명한 후, 최종 JSON을 출력해주세요.`
}
```

### 3. Self-Consistency (여러 번 실행 후 합의)

```javascript
// Code 노드: OpenAI를 3번 호출하여 가장 일관된 결과 선택
const results = [];

for (let i = 0; i < 3; i++) {
  const response = await $http.post({
    url: 'https://api.openai.com/v1/chat/completions',
    headers: {
      'Authorization': `Bearer ${$credentials.openAiApi.apiKey}`,
      'Content-Type': 'application/json'
    },
    body: {
      model: 'gpt-3.5-turbo',
      messages: [...],
      temperature: 0.7  // 약간의 변동성
    }
  });

  results.push(JSON.parse(response.choices[0].message.content));
}

// 가장 많이 나온 결과 선택
const sentiments = results.map(r => r.sentiment);
const mostCommon = sentiments.sort((a,b) =>
  sentiments.filter(v => v === a).length - sentiments.filter(v => v === b).length
).pop();

return results.find(r => r.sentiment === mostCommon);
```

### 4. Prompt Caching (비용 절감)

```javascript
// 자주 사용하는 프롬프트는 변수로 저장
const SYSTEM_PROMPT = `당신은 고객 서비스 전문가입니다...`;

// n8n Static Data에 저장하거나 환경 변수로 관리
```

---

## 📊 실시간 대시보드용 데이터 수집

### Google Analytics 4 실시간 데이터

```javascript
// HTTP Request to GA4 API
{
  "method": "POST",
  "url": "https://analyticsdata.googleapis.com/v1beta/properties/YOUR_PROPERTY_ID:runRealtimeReport",
  "headers": {
    "Authorization": "Bearer {{$credentials.googleApi.oauthTokenData.access_token}}",
    "Content-Type": "application/json"
  },
  "body": {
    "dimensions": [
      {"name": "country"},
      {"name": "deviceCategory"},
      {"name": "eventName"}
    ],
    "metrics": [
      {"name": "activeUsers"},
      {"name": "screenPageViews"}
    ],
    "minuteRanges": [{
      "name": "0-4 minutes ago",
      "startMinutesAgo": 4,
      "endMinutesAgo": 0
    }]
  }
}

// Code 노드: 데이터 정리
const rows = $json.rows || [];

return rows.map(row => ({
  country: row.dimensionValues[0].value,
  device: row.dimensionValues[1].value,
  event: row.dimensionValues[2].value,
  active_users: parseInt(row.metricValues[0].value),
  pageviews: parseInt(row.metricValues[1].value),
  timestamp: new Date().toISOString()
}));
```

### Stripe 매출 데이터 실시간 수집

```javascript
// HTTP Request to Stripe API
{
  "method": "GET",
  "url": "https://api.stripe.com/v1/charges",
  "headers": {
    "Authorization": "Bearer {{$credentials.stripeApi.secretKey}}"
  },
  "qs": {
    "limit": 100,
    "created[gte]": Math.floor(Date.now() / 1000) - 3600  // 최근 1시간
  }
}

// Code 노드: OpenAI로 매출 인사이트 생성
const charges = $json.data;
const totalRevenue = charges.reduce((sum, c) => sum + c.amount, 0) / 100;
const successfulCharges = charges.filter(c => c.status === 'succeeded').length;
const avgTransaction = totalRevenue / successfulCharges;

// OpenAI에 데이터 요약 요청
const prompt = `다음 최근 1시간 매출 데이터를 분석하여 경영진에게 보고할 한 문장 인사이트를 생성해주세요:

- 총 매출: $${totalRevenue.toFixed(2)}
- 거래 건수: ${successfulCharges}건
- 평균 거래액: $${avgTransaction.toFixed(2)}

간결하고 액션 가능한 인사이트를 제공해주세요.`;

return { prompt, data: { totalRevenue, successfulCharges, avgTransaction } };
```

---

## 📁 제공 파일

### workflows/
- `gmail-ai-support.json` - Gmail + AI 고객 지원 시스템
- `ga4-realtime-dashboard.json` - GA4 실시간 대시보드
- `stripe-revenue-insights.json` - Stripe 매출 AI 분석
- `multi-channel-support.json` - 다중 채널 통합 지원

### scripts/
- `test-openai-api.js` - OpenAI API 테스트
- `benchmark-prompts.py` - 프롬프트 성능 벤치마크
- `cost-calculator.js` - AI API 비용 계산기

---

## 💰 AI API 비용 최적화

### 1. 모델 선택 전략

```javascript
// 간단한 작업: GPT-3.5-turbo
const simpleAnalysis = {
  model: "gpt-3.5-turbo",
  cost: "$0.0015 / 1K tokens"
};

// 복잡한 작업: GPT-4
const complexAnalysis = {
  model: "gpt-4",
  cost: "$0.03 / 1K tokens"
};

// 규칙: 먼저 GPT-3.5로 시도, 신뢰도 낮으면 GPT-4로 재시도
if (firstResponse.confidence < 70) {
  // GPT-4로 재분석
}
```

### 2. 프롬프트 길이 최적화

```javascript
// ❌ 나쁜 예: 불필요하게 긴 프롬프트
const badPrompt = `
당신은 세계 최고의 고객 서비스 전문가이며...
(500 단어의 불필요한 설명)
`;

// ✅ 좋은 예: 간결하고 명확한 프롬프트
const goodPrompt = `고객 이메일의 감정을 '긍정', '부정', '중립'로 분류하고 신뢰도(0-100)를 JSON으로 반환하세요.`;
```

### 3. 캐싱 및 재사용

```javascript
// 동일한 질문에 대한 응답은 캐시
const cache = {};

const cacheKey = `sentiment_${emailBody.substring(0, 50)}`;
if (cache[cacheKey]) {
  return cache[cacheKey];
}

const response = await callOpenAI(...);
cache[cacheKey] = response;

return response;
```

---

**다음 단계**: 종합 프로젝트 구현 → [05-use-cases](../../05-use-cases/README.md)
