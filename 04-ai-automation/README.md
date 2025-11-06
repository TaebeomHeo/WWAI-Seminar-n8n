# 04. AI 노드 활용 및 지능형 자동화

## 📚 학습 목표

- OpenAI API를 n8n과 연동하기
- 이메일 자동 분류 및 감정 분석
- AI 기반 콘텐츠 생성
- 고객 문의 자동 응답 시스템 구축

---

## 🔧 사전 준비

### OpenAI API 키 발급

1. **OpenAI 계정 생성**
   - https://platform.openai.com 접속
   - 회원가입 및 로그인

2. **API 키 생성**
   - "API Keys" 메뉴 이동
   - "Create new secret key" 클릭
   - 키 복사 및 안전하게 보관

3. **요금제 확인**
   - GPT-3.5-turbo: 저렴하고 빠름 (입력 $0.0015/1K 토큰)
   - GPT-4: 더 정확하고 강력 (입력 $0.03/1K 토큰)
   - https://openai.com/pricing

4. **n8n에 인증 정보 추가**
   - n8n → Credentials → Add Credential
   - "OpenAI" 선택
   - API Key 입력

---

## 🎯 실습 1: AI 기반 이메일 감정 분석

### 목표
고객 이메일을 자동으로 분석하여 감정(긍정/부정/중립)과 우선순위를 판단합니다.

### 단계별 가이드

#### 1단계: Webhook으로 이메일 데이터 수신
```
HTTP Method: POST
Path: email-analysis
```

**테스트 데이터 구조:**
```json
{
  "from": "customer@example.com",
  "subject": "제품 사용 중 문제가 있습니다",
  "body": "안녕하세요. 구매한 제품이 작동하지 않습니다. 빨리 해결해주세요."
}
```

#### 2단계: Set 노드로 데이터 정리
```javascript
// 이메일 데이터 구조화
{
  "from": "={{$json.body.from}}",
  "subject": "={{$json.body.subject}}",
  "email_body": "={{$json.body.body}}",
  "received_at": "={{$now}}"
}
```

#### 3단계: OpenAI 노드 추가 - 감정 분석

**노드 설정:**
```
Model: gpt-3.5-turbo
Operation: Message a Model
```

**System Message (프롬프트 엔지니어링):**
```
당신은 고객 서비스 전문가입니다.
다음 이메일의 감정을 분석하여 JSON 형식으로 응답해주세요.

응답 형식:
{
  "sentiment": "긍정" | "부정" | "중립",
  "confidence": 0-100 사이의 숫자,
  "key_emotions": ["감정1", "감정2"],
  "urgency_level": "낮음" | "보통" | "높음" | "긴급"
}
```

**User Message:**
```
제목: {{$json.subject}}
내용: {{$json.email_body}}
```

#### 4단계: OpenAI 노드 추가 - 카테고리 분류

**System Message:**
```
다음 고객 이메일을 적절한 카테고리로 분류해주세요.

카테고리:
- 기술지원: 제품 사용법, 오류, 설치 문제
- 판매문의: 가격, 구매, 견적 요청
- 환불요청: 취소, 반품, 환불 관련
- 제품문의: 기능, 스펙, 호환성
- 칭찬: 긍정적 피드백
- 불만: 부정적 피드백
- 기타: 위 카테고리에 해당하지 않는 경우

JSON 형식으로 응답:
{
  "category": "카테고리명",
  "subcategory": "세부 카테고리",
  "confidence": 0-100
}
```

#### 5단계: Code 노드로 종합 분석

```javascript
const emailData = $node["Set"].json;
const sentimentData = JSON.parse($node["OpenAI Sentiment"].json.message.content);
const categoryData = JSON.parse($node["OpenAI Category"].json.message.content);

// 우선순위 점수 계산
let priorityScore = 0;

// 감정 기반 점수
if (sentimentData.sentiment === "부정") priorityScore += 3;
else if (sentimentData.sentiment === "중립") priorityScore += 1;

// 긴급도 기반 점수
const urgencyScores = {
  "긴급": 4,
  "높음": 3,
  "보통": 1,
  "낮음": 0
};
priorityScore += urgencyScores[sentimentData.urgency_level] || 0;

// 카테고리 기반 점수
const categoryScores = {
  "환불요청": 3,
  "불만": 3,
  "기술지원": 2,
  "판매문의": 1
};
priorityScore += categoryScores[categoryData.category] || 0;

// 긴급 키워드 확인
const urgentKeywords = ["긴급", "빨리", "즉시", "오류", "문제", "안됨", "불가능"];
const hasUrgentKeyword = urgentKeywords.some(keyword =>
  emailData.subject.includes(keyword) || emailData.email_body.includes(keyword)
);
if (hasUrgentKeyword) priorityScore += 2;

// 최종 우선순위 결정
let priority = "낮음";
if (priorityScore >= 7) priority = "긴급";
else if (priorityScore >= 5) priority = "높음";
else if (priorityScore >= 3) priority = "보통";

return {
  ...emailData,
  sentiment: sentimentData.sentiment,
  sentiment_confidence: sentimentData.confidence,
  key_emotions: sentimentData.key_emotions,
  category: categoryData.category,
  subcategory: categoryData.subcategory,
  priority: priority,
  priority_score: priorityScore,
  analyzed_at: new Date().toISOString()
};
```

#### 6단계: OpenAI 노드 - 자동 응답 초안 생성

**System Message:**
```
당신은 전문적이고 친절한 고객 서비스 담당자입니다.
다음 고객 이메일에 대한 답변 초안을 작성해주세요.

답변 작성 가이드라인:
1. 고객의 감정을 이해하고 공감 표현
2. 문제에 대한 구체적인 해결책 또는 다음 단계 안내
3. 필요시 추가 정보 요청
4. 정중하고 전문적인 톤 유지
5. 200-300자 내외로 작성

고객 정보:
- 감정: {{$json.sentiment}}
- 카테고리: {{$json.category}}
- 우선순위: {{$json.priority}}

원본 이메일:
제목: {{$json.subject}}
내용: {{$json.email_body}}
```

#### 7단계: IF 노드로 우선순위 분기
```
Condition: ={{$json.priority}}
Operation: equal
Value: "긴급"
```

#### 8단계: 알림 및 저장

**True (긴급) 분기:**
- Slack 알림: 즉시 담당자에게 알림
- Google Sheets: 빨간색으로 강조하여 저장

**False (일반) 분기:**
- Google Sheets: 일반 저장
- 자동 응답 이메일 전송 (선택사항)

### 📝 실습 과제

**과제 1**: 다국어 지원
- 이메일 언어 자동 감지
- 해당 언어로 자동 응답 생성

**과제 2**: 감정 추세 분석
- 고객별 감정 히스토리 추적
- 부정적 감정 증가 시 담당자 알림

**과제 3**: 자동 티켓 생성
- 분석 결과를 기반으로 Jira/Zendesk 티켓 자동 생성
- 우선순위와 담당자 자동 할당

---

## 🎯 실습 2: AI 기반 콘텐츠 생성 및 번역

### 목표
블로그 포스트 초안을 자동 생성하고, 다국어로 번역합니다.

### 단계별 가이드

#### 1단계: 주제 입력 (Manual Trigger + Set 노드)
```javascript
{
  "topic": "n8n을 활용한 업무 자동화",
  "target_audience": "중소기업 경영자",
  "tone": "전문적이면서 친근한",
  "word_count": 800
}
```

#### 2단계: OpenAI - 아웃라인 생성

**System Message:**
```
블로그 콘텐츠 전문가로서 다음 주제에 대한 블로그 포스트 아웃라인을 작성해주세요.

요구사항:
- 도입부, 본문 3-5개 섹션, 결론으로 구성
- 각 섹션마다 핵심 포인트 2-3개씩 포함
- SEO 친화적인 제목과 부제목
- 독자의 관심을 끄는 후킹 포인트 포함

JSON 형식으로 응답:
{
  "title": "메인 제목",
  "hook": "독자를 끄는 첫 문장",
  "sections": [
    {
      "heading": "섹션 제목",
      "key_points": ["포인트1", "포인트2"]
    }
  ],
  "conclusion": "결론 요약"
}
```

**User Message:**
```
주제: {{$json.topic}}
대상 독자: {{$json.target_audience}}
톤: {{$json.tone}}
목표 단어 수: {{$json.word_count}}
```

#### 3단계: OpenAI - 전체 콘텐츠 생성

**System Message:**
```
전문 블로그 작가로서 다음 아웃라인을 바탕으로 완성된 블로그 포스트를 작성해주세요.

요구사항:
- 각 섹션을 자세하고 구체적으로 작성
- 실용적인 예시와 팁 포함
- 자연스러운 문장 흐름
- SEO 키워드 자연스럽게 배치
- 목표 단어 수 준수

마크다운 형식으로 작성해주세요.
```

**User Message:**
```
주제: {{$node["Set"].json.topic}}
아웃라인: {{$node["OpenAI Outline"].json.message.content}}
목표 단어 수: {{$node["Set"].json.word_count}}
```

#### 4단계: 번역 (여러 언어로 동시 번역)

**Split In Batches 노드:**
```javascript
// 번역할 언어 목록
[
  { "language": "영어", "code": "en" },
  { "language": "일본어", "code": "ja" },
  { "language": "중국어", "code": "zh" }
]
```

**OpenAI Translation 노드:**
```
System Message:
"전문 번역가로서 다음 블로그 포스트를 {{$json.language}}로 번역해주세요.
문화적 맥락을 고려하고, 자연스러운 표현을 사용하며, 원문의 톤을 유지해주세요."

User Message:
"{{$node['OpenAI Content'].json.message.content}}"
```

#### 5단계: 결과 정리 및 저장

```javascript
const originalContent = $node["OpenAI Content"].json.message.content;
const translations = $node["OpenAI Translation"].json;

// Google Docs 또는 Notion에 저장
return {
  topic: $node["Set"].json.topic,
  original_language: "한국어",
  original_content: originalContent,
  translations: translations.map(t => ({
    language: t.language,
    content: t.translated_content
  })),
  created_at: new Date().toISOString(),
  word_count: originalContent.split(' ').length
};
```

### 📝 실습 과제

**과제 1**: SEO 메타데이터 생성
- 메타 제목, 메타 설명, 키워드 자동 생성
- OpenGraph 이미지 프롬프트 생성

**과제 2**: 소셜 미디어 포스트 생성
- 블로그 내용을 기반으로 Twitter, LinkedIn 포스트 생성
- 각 플랫폼에 맞는 톤과 길이로 조정

**과제 3**: 이미지 프롬프트 생성
- 각 섹션에 어울리는 DALL-E 프롬프트 자동 생성
- (선택) DALL-E API로 이미지 자동 생성

---

## 🎯 실습 3: AI 챗봇 (고객 문의 자동 응답)

### 목표
고객 질문에 자동으로 답변하는 AI 챗봇을 구현합니다.

### 단계별 가이드

#### 1단계: 지식 베이스 준비

**Google Sheets 구조: `FAQ`**

| 질문 | 답변 | 카테고리 | 키워드 |
|------|------|----------|--------|
| 배송은 얼마나 걸리나요? | 일반적으로 2-3일 소요됩니다 | 배송 | 배송,시간,기간 |
| 환불 정책은? | 구매 후 7일 이내 가능합니다 | 환불 | 환불,취소,반품 |

#### 2단계: Webhook으로 질문 수신
```json
{
  "user_id": "user123",
  "question": "제품 배송은 얼마나 걸리나요?"
}
```

#### 3단계: Google Sheets에서 FAQ 읽기
```
Operation: Read
Sheet: FAQ
Range: A2:D
```

#### 4단계: OpenAI - RAG 방식 응답 생성

**System Message:**
```
당신은 고객 서비스 AI 어시스턴트입니다.
다음 FAQ 데이터베이스를 참고하여 고객 질문에 답변해주세요.

FAQ 데이터베이스:
{{$node["Google Sheets"].json}}

답변 가이드라인:
1. FAQ에서 관련 정보를 찾아 활용
2. 찾을 수 없으면 정중하게 담당자 연결 안내
3. 친절하고 명확하게 답변
4. 100자 이내로 간결하게 작성
5. 필요시 추가 질문 유도

JSON 형식으로 응답:
{
  "answer": "답변 내용",
  "confidence": 0-100,
  "related_faqs": ["관련 FAQ 인덱스"],
  "needs_human": true/false
}
```

**User Message:**
```
고객 질문: {{$json.question}}
```

#### 5단계: 응답 전송 및 로깅

```javascript
const response = JSON.parse($node["OpenAI"].json.message.content);

// 로그 저장
const logEntry = {
  user_id: $json.user_id,
  question: $json.question,
  answer: response.answer,
  confidence: response.confidence,
  needs_human: response.needs_human,
  timestamp: new Date().toISOString()
};

// 신뢰도가 낮으면 담당자에게 에스컬레이션
if (response.confidence < 70 || response.needs_human) {
  // Slack 알림
  return {
    ...logEntry,
    escalated: true
  };
}

return {
  ...logEntry,
  escalated: false
};
```

### 📝 실습 과제

**과제 1**: 대화 컨텍스트 유지
- 이전 대화 내역을 저장하고 활용
- 연속된 질문에 대한 문맥 이해

**과제 2**: 감성 분석 통합
- 고객의 감정 상태 파악
- 부정적 감정 감지 시 즉시 담당자 연결

**과제 3**: 다국어 챗봇
- 질문 언어 자동 감지
- 해당 언어로 자동 응답

---

## 📁 참고 자료

### data/ 폴더
- `sample-emails.json` - 테스트용 이메일 데이터
- `blog-topics.json` - 블로그 주제 샘플
- `faq-database.csv` - FAQ 데이터베이스 샘플

### solutions/ 폴더
- `01-email-analysis.json` - 이메일 감정 분석 워크플로우
- `02-content-generation.json` - AI 콘텐츠 생성 워크플로우
- `03-ai-chatbot.json` - AI 챗봇 워크플로우

---

## 💡 프롬프트 엔지니어링 팁

### 1. 명확한 역할 정의
```
좋은 예: "당신은 10년 경력의 고객 서비스 전문가입니다."
나쁜 예: "이메일을 분석해주세요."
```

### 2. 구체적인 출력 형식 지정
```
좋은 예: "JSON 형식으로 응답: {\"sentiment\": \"긍정/부정/중립\"}"
나쁜 예: "감정을 분석해주세요."
```

### 3. Few-Shot 예제 제공
```
System Message:
"다음 예제를 참고하여 분류해주세요:

예제 1:
입력: '제품이 훌륭합니다!'
출력: {\"sentiment\": \"긍정\", \"confidence\": 95}

예제 2:
입력: '배송이 늦어요'
출력: {\"sentiment\": \"부정\", \"confidence\": 85}"
```

### 4. 제약사항 명시
```
"150자 이내로 작성해주세요."
"전문적이면서도 친근한 톤을 사용해주세요."
"마크다운 형식으로 작성해주세요."
```

### 5. Chain of Thought (단계적 사고)
```
"다음 단계로 분석해주세요:
1. 먼저 고객의 주요 관심사를 파악
2. 감정 상태를 분석
3. 적절한 응답 전략 수립
4. 최종 답변 작성"
```

---

## ⚠️ 주의사항 및 베스트 프랙티스

### 1. API 비용 관리
```javascript
// 토큰 수 예측 (대략 1단어 = 1.3토큰)
const estimateTokens = (text) => {
  return Math.ceil(text.split(' ').length * 1.3);
};

// 비용 계산
const costPerRequest = (inputTokens, outputTokens) => {
  // GPT-3.5-turbo 기준
  const inputCost = inputTokens / 1000 * 0.0015;
  const outputCost = outputTokens / 1000 * 0.002;
  return inputCost + outputCost;
};
```

### 2. 응답 검증
```javascript
// OpenAI 응답 파싱 시 에러 처리
try {
  const response = JSON.parse($json.message.content);
  return response;
} catch (error) {
  // JSON 파싱 실패 시 재시도 또는 기본값
  return {
    error: true,
    message: "AI 응답 파싱 실패",
    raw_response: $json.message.content
  };
}
```

### 3. 응답 시간 최적화
- GPT-3.5-turbo 우선 사용 (더 빠르고 저렴)
- 필요한 경우에만 GPT-4 사용
- 프롬프트 길이 최소화

### 4. 보안
- API 키를 코드에 하드코딩하지 않기
- n8n Credentials 사용
- 민감한 정보는 로그에 남기지 않기

---

## ✅ 완료 체크리스트

- [ ] OpenAI API 인증 설정 완료
- [ ] 이메일 감정 분석 시스템 구현
- [ ] 우선순위 자동 판단 로직 작동 확인
- [ ] AI 콘텐츠 생성 및 번역 워크플로우 완성
- [ ] AI 챗봇 구현 및 테스트
- [ ] 프롬프트 엔지니어링 기법 이해
- [ ] 모든 실습 과제 완료

---

**이전 단계**: [03. 웹 스크래핑](../03-web-scraping/README.md)
**다음 단계**: [05. 실무 유스케이스](../05-use-cases/README.md)
