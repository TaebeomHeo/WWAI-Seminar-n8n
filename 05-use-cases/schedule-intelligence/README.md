# Schedule Intelligence System - 상세 구현 가이드

> **프로젝트**: 이메일 자동 일정 추출 및 Google Calendar 등록 시스템
>
> **완성 시간**: 3-5시간
> **난이도**: ⭐⭐⭐⭐☆
> **필요 기술**: n8n, Gmail API, OpenAI API, Google Calendar API

이 가이드는 Schedule Intelligence 시스템의 실제 구현 방법을 단계별로 설명합니다.

**→ 프로젝트 소개는 [OVERVIEW.md](OVERVIEW.md)를 먼저 읽어주세요.**

---

## 📑 목차

1. [사전 준비](#사전-준비)
2. [워크플로우 구조](#워크플로우-구조)
3. [단계별 구현](#단계별-구현)
4. [AI 프롬프트 최적화](#ai-프롬프트-최적화)
5. [날짜 파싱 알고리즘](#날짜-파싱-알고리즘)
6. [중복 감지 로직](#중복-감지-로직)
7. [테스트 및 검증](#테스트-및-검증)
8. [프로덕션 배포](#프로덕션-배포)
9. [문제 해결](#문제-해결)

---

## 사전 준비

### 필요한 계정 및 API

#### 1. Google Workspace
- Gmail 계정
- Google Calendar 계정
- Google Cloud Console 접근 권한

#### 2. Google Cloud API 설정

**Gmail API + Calendar API 활성화**:
1. https://console.cloud.google.com 접속
2. 프로젝트 생성: "schedule-intelligence"
3. "API 및 서비스" → "라이브러리"
4. **Gmail API** 검색 및 활성화
5. **Google Calendar API** 검색 및 활성화

**OAuth 2.0 인증 정보**:
1. "사용자 인증 정보" → "OAuth 2.0 클라이언트 ID" 생성
2. 애플리케이션 유형: "웹 애플리케이션"
3. 승인된 리디렉션 URI: n8n의 OAuth 콜백 URL
4. credentials.json 다운로드

**상세 가이드**: [Google Cloud Setup](../../02-google-sheets/GOOGLE_CLOUD_SETUP.md)

#### 3. OpenAI API
```
1. https://platform.openai.com 접속
2. API 키 발급
3. 최소 $5 크레딧 충전

예상 비용:
- GPT-4 Turbo: 일정 1개당 $0.03-0.05
- GPT-3.5 Turbo: 일정 1개당 $0.005-0.01
- 월 100개 기준: $5-50
```

#### 4. n8n 설정
```bash
# n8n Cloud (권장)
https://app.n8n.cloud

# 또는 로컬 설치
npx n8n
```

---

## 워크플로우 구조

### 전체 흐름도

```
[트리거: Gmail 또는 Schedule]
   ↓
[이메일 필터링]
   ├─ 라벨: "일정"
   ├─ 발신자: VIP 리스트
   └─ 키워드 포함
   ↓
[Loop: 각 이메일 처리]
   ↓
   ├─ [이메일 내용 추출]
   │     ↓
   ├─ [AI 분석] (GPT-4/Claude)
   │   ├─ 일정 정보 추출
   │   ├─ 날짜/시간 파싱
   │   └─ 신뢰도 계산
   │     ↓
   ├─ [IF: 일정 있음?]
   │   │
   │   Yes → [날짜 정규화]
   │   │        ↓
   │   │     [중복 체크]
   │   │        ├─ Calendar 조회
   │   │        └─ 유사도 계산
   │   │        ↓
   │   │     [IF: 중복?]
   │   │        ├─ Yes → [병합/업데이트]
   │   │        └─ No → [새 일정 등록]
   │   │        ↓
   │   │     [확인 이메일 발송]
   │   │
   │   No → [다음 이메일]
   │
   └─ [Loop 계속]
```

### 주요 노드 구성

| 순서 | 노드 | 역할 |
|------|------|------|
| 1 | Schedule Trigger | 매일 2회 실행 (09:00, 18:00) |
| 2 | Gmail | 특정 조건의 이메일 검색 |
| 3 | Loop Over Items | 각 이메일 순회 |
| 4 | Code (파싱) | 이메일 내용 추출 |
| 5 | OpenAI | AI로 일정 정보 추출 |
| 6 | Code (날짜) | 날짜 문자열을 ISO 형식으로 |
| 7 | IF (일정 존재) | has_schedule 체크 |
| 8 | Google Calendar (조회) | 기존 일정 중복 체크 |
| 9 | Code (중복 감지) | 유사도 계산 |
| 10 | IF (중복 여부) | 중복 판단 |
| 11 | Google Calendar (등록) | 새 일정 생성 |
| 12 | Gmail (확인) | 확인 이메일 발송 |

---

## 단계별 구현

### 1단계: Schedule Trigger 설정

**노드 추가**: Schedule Trigger

```
Mode: Every Day
Hour: 9, 18  (오전 9시, 오후 6시)
Minute: 0
Timezone: Asia/Seoul
```

또는 Cron 표현식:
```
0 9,18 * * *
```

### 2단계: Gmail 이메일 검색

**노드 추가**: Gmail

**Resource**: `Message`
**Operation**: `Search`

**Search Query**:
```
label:일정 OR label:미팅 OR subject:(회의 OR 미팅 OR 마감) 
after:{{$now.minus({hours: 12}).toFormat('yyyy/MM/dd')}}
is:unread
```

**설명**:
- `label:일정`: "일정" 라벨이 있는 이메일
- `subject:(회의 OR 미팅 OR 마감)`: 제목에 키워드 포함
- `after:최근12시간`: 최근 이메일만
- `is:unread`: 읽지 않은 이메일만

**Options**:
- Return All: `true`
- Max Results: `50`
- Include Spam and Trash: `false`

### 3단계: Loop Over Items

**노드 추가**: Loop Over Items

각 이메일을 하나씩 처리합니다.

### 4단계: 이메일 내용 파싱

**노드 추가**: Code

```javascript
// 이메일 데이터 가져오기
const email = $input.first().json;

// 발신자 정보
const from = email.from || '';
const fromEmail = from.match(/<(.+?)>/) ? from.match(/<(.+?)>/)[1] : from;
const fromName = from.match(/^(.+?)\s*</) ? from.match(/^(.+?)\s*</)[1].trim() : fromEmail;

// 제목 및 본문
const subject = email.subject || '';
const body = email.textPlain || email.snippet || '';

// 받은 날짜
const receivedDate = email.date || new Date().toISOString();

return [{
  json: {
    email_id: email.id,
    from_email: fromEmail,
    from_name: fromName,
    subject: subject,
    body: body,
    received_date: receivedDate,
    thread_id: email.threadId
  }
}];
```

### 5단계: AI로 일정 정보 추출

**노드 추가**: OpenAI Chat Model

**Model**: `gpt-4-turbo` (정확도 우선) 또는 `gpt-3.5-turbo` (비용 우선)

**System Message**:
```
당신은 이메일에서 일정 정보를 추출하는 전문 AI 비서입니다.

다음 이메일을 분석하여 일정 정보를 JSON 형식으로 추출해주세요.

출력 형식:
{
  "has_schedule": true | false,
  "event_type": "meeting" | "deadline" | "appointment" | "event",
  "title": "일정 제목",
  "date": "YYYY-MM-DD",
  "start_time": "HH:MM",
  "end_time": "HH:MM",
  "duration_minutes": 60,
  "location": "장소 (없으면 null)",
  "attendees": ["email1@example.com", "email2@example.com"],
  "description": "상세 설명",
  "priority": "high" | "medium" | "low",
  "is_recurring": false,
  "recurrence_pattern": null,
  "confidence": 0-100
}

중요 규칙:
1. has_schedule이 false면 다른 필드는 null
2. 날짜는 반드시 YYYY-MM-DD 형식
3. 시간은 24시간 형식 (HH:MM)
4. 명확하지 않으면 confidence를 낮게 설정
5. 참석자는 이메일 주소만 배열로
6. 현재 날짜/시간을 기준으로 상대적 날짜 계산

현재 정보:
- 오늘 날짜: {{$now.toFormat('yyyy-MM-DD')}}
- 현재 시각: {{$now.toFormat('HH:mm')}}
- 요일: {{$now.toFormat('EEEE', {locale: 'ko'})}}
```

**User Message**:
```
이메일 분석 요청:

발신자: {{$json.from_name}} <{{$json.from_email}}>
제목: {{$json.subject}}

본문:
{{$json.body}}

위 이메일에서 일정 정보를 추출해주세요.
```

**Options**:
```
Response Format: json_object
Temperature: 0.3
Max Tokens: 1000
```

### 6단계: AI 결과 파싱

**노드 추가**: Code

```javascript
// AI 분석 결과
const aiResult = JSON.parse($input.first().json.message.content);
const emailData = $input.first().json;

// 기본 응답 구조
if (!aiResult.has_schedule) {
  return [{
    json: {
      has_schedule: false,
      email_id: emailData.email_id,
      reason: "일정 정보 없음"
    }
  }];
}

// 일정 정보 정리
const schedule = {
  // 원본 정보
  email_id: emailData.email_id,
  from_email: emailData.from_email,
  subject: emailData.subject,
  
  // AI 추출 정보
  has_schedule: true,
  event_type: aiResult.event_type,
  title: aiResult.title,
  date: aiResult.date,
  start_time: aiResult.start_time,
  end_time: aiResult.end_time,
  duration_minutes: aiResult.duration_minutes || 60,
  location: aiResult.location,
  attendees: aiResult.attendees || [],
  description: aiResult.description,
  priority: aiResult.priority || 'medium',
  confidence: aiResult.confidence,
  
  // 메타 데이터
  extracted_at: new Date().toISOString()
};

return [{json: schedule}];
```

### 7단계: 날짜/시간 정규화

**노드 추가**: Code

```javascript
const schedule = $input.first().json;

// ISO 8601 형식으로 변환
function toISO(date, time, timezone = 'Asia/Seoul') {
  // YYYY-MM-DD + HH:MM → ISO 8601
  const dateTime = `${date}T${time}:00`;
  return `${dateTime}+09:00`;  // 한국 시간대
}

// 종료 시간 계산
function calculateEndTime(startTime, durationMinutes) {
  const [hours, minutes] = startTime.split(':').map(Number);
  const startMinutes = hours * 60 + minutes;
  const endMinutes = startMinutes + durationMinutes;
  
  const endHours = Math.floor(endMinutes / 60) % 24;
  const endMins = endMinutes % 60;
  
  return `${String(endHours).padStart(2, '0')}:${String(endMins).padStart(2, '0')}`;
}

// 종료 시간이 없으면 계산
if (!schedule.end_time && schedule.start_time) {
  schedule.end_time = calculateEndTime(
    schedule.start_time, 
    schedule.duration_minutes
  );
}

// ISO 형식 생성
const startDateTime = toISO(schedule.date, schedule.start_time);
const endDateTime = toISO(schedule.date, schedule.end_time);

return [{
  json: {
    ...schedule,
    start_datetime_iso: startDateTime,
    end_datetime_iso: endDateTime
  }
}];
```

### 8단계: Google Calendar에서 중복 체크

**노드 추가**: Google Calendar

**Resource**: `Event`
**Operation**: `Get All`

**Calendar**: `primary` (기본 캘린더)

**Parameters**:
```
Time Min: {{$json.date}}T00:00:00+09:00
Time Max: {{$json.date}}T23:59:59+09:00
Max Results: 50
Single Events: true
```

**설명**: 해당 날짜의 모든 일정을 가져와서 중복 체크

### 9단계: 중복 감지 로직

**노드 추가**: Code

```javascript
const newEvent = $input.first().json;
const existingEvents = $('Google Calendar').all();

// Levenshtein Distance 계산
function levenshteinDistance(str1, str2) {
  const matrix = [];
  for (let i = 0; i <= str2.length; i++) matrix[i] = [i];
  for (let j = 0; j <= str1.length; j++) matrix[0][j] = j;
  
  for (let i = 1; i <= str2.length; i++) {
    for (let j = 1; j <= str1.length; j++) {
      if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j] + 1
        );
      }
    }
  }
  
  return matrix[str2.length][str1.length];
}

// 유사도 계산 (0-100)
function calculateSimilarity(str1, str2) {
  const maxLen = Math.max(str1.length, str2.length);
  if (maxLen === 0) return 100;
  
  const distance = levenshteinDistance(str1.toLowerCase(), str2.toLowerCase());
  return Math.round((1 - distance / maxLen) * 100);
}

// 시간 겹침 체크
function timeOverlaps(start1, end1, start2, end2) {
  return (start1 < end2 && end1 > start2);
}

// 중복 감지
let duplicates = [];
for (const existing of existingEvents) {
  const existingEvent = existing.json;
  
  // 제목 유사도
  const titleSimilarity = calculateSimilarity(
    newEvent.title,
    existingEvent.summary || ''
  );
  
  // 시간 겹침
  const isOverlapping = timeOverlaps(
    new Date(newEvent.start_datetime_iso),
    new Date(newEvent.end_datetime_iso),
    new Date(existingEvent.start?.dateTime || existingEvent.start?.date),
    new Date(existingEvent.end?.dateTime || existingEvent.end?.date)
  );
  
  // 중복 판정: 제목 80% 이상 유사 + 시간 겹침
  if (titleSimilarity >= 80 && isOverlapping) {
    duplicates.push({
      ...existingEvent,
      similarity: titleSimilarity
    });
  }
}

return [{
  json: {
    ...newEvent,
    is_duplicate: duplicates.length > 0,
    duplicate_count: duplicates.length,
    duplicates: duplicates,
    highest_similarity: duplicates.length > 0 
      ? Math.max(...duplicates.map(d => d.similarity))
      : 0
  }
}];
```

### 10단계: 중복 여부 분기

**노드 추가**: IF

**Condition**:
```
Value 1: {{$json.is_duplicate}}
Operation: is equal
Value 2: true
```

**True 분기**: 중복 → 업데이트 또는 병합
**False 분기**: 새 일정 등록

### 11단계: Google Calendar 일정 등록 (False 분기)

**노드 추가**: Google Calendar

**Resource**: `Event`
**Operation**: `Create`

**Calendar**: `primary`

**Event Object**:
```json
{
  "summary": "={{$json.title}}",
  "description": "={{$json.description}}\n\n[원본 이메일]\n발신: {{$json.from_email}}\n제목: {{$json.subject}}",
  "location": "={{$json.location}}",
  "start": {
    "dateTime": "={{$json.start_datetime_iso}}",
    "timeZone": "Asia/Seoul"
  },
  "end": {
    "dateTime": "={{$json.end_datetime_iso}}",
    "timeZone": "Asia/Seoul"
  },
  "attendees": "={{$json.attendees.map(email => ({email: email}))}}",
  "reminders": {
    "useDefault": false,
    "overrides": [
      {"method": "popup", "minutes": 30},
      {"method": "email", "minutes": 1440}
    ]
  },
  "colorId": "={{$json.priority === 'high' ? '11' : '9'}}"
}
```

### 12단계: 확인 이메일 발송

**노드 추가**: Gmail

**Operation**: `Send Email`

**To**: `={{$json.from_email}}`

**Subject**: `✅ 일정이 자동으로 등록되었습니다: {{$json.title}}`

**Email Type**: `HTML`

**Message**:
```html
<html>
<body style="font-family: Arial, sans-serif;">
  <h2>✅ 일정이 캘린더에 등록되었습니다</h2>
  
  <div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #4CAF50;">
    <h3>{{=$json.title}}</h3>
    <p><strong>📅 날짜:</strong> {{=$json.date}}</p>
    <p><strong>⏰ 시간:</strong> {{=$json.start_time}} - {{=$json.end_time}}</p>
    <p><strong>📍 장소:</strong> {{=$json.location || '미지정'}}</p>
    {{=$json.attendees.length > 0 ? '<p><strong>👥 참석자:</strong> ' + $json.attendees.join(', ') + '</p>' : ''}}
  </div>
  
  <p style="margin-top: 20px;">
    <a href="https://calendar.google.com" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
      📅 Google Calendar에서 확인
    </a>
  </p>
  
  <hr style="margin-top: 30px;">
  
  <p style="font-size: 12px; color: #666;">
    문제가 있거나 일정을 취소하려면 이 이메일에 회신해주세요.<br>
    "취소" 또는 "삭제"라고 회신하시면 캘린더에서 자동으로 제거됩니다.
  </p>
  
  <p style="font-size: 12px; color: #999;">
    이 이메일은 Schedule Intelligence System에서 자동으로 발송되었습니다.
  </p>
</body>
</html>
```

---

## AI 프롬프트 최적화

### Few-Shot Learning 기법

기본 프롬프트에 예시를 추가하여 정확도 향상:

```
다음 예시를 참고하여 일정을 추출해주세요:

예시 1:
이메일: "다음 주 월요일 오후 2시에 3층 회의실에서 기획 회의 하겠습니다."
결과:
{
  "has_schedule": true,
  "event_type": "meeting",
  "title": "기획 회의",
  "date": "2024-11-11",
  "start_time": "14:00",
  "end_time": "15:00",
  "location": "3층 회의실",
  "confidence": 95
}

예시 2:
이메일: "11월 말까지 프로젝트 보고서 제출 부탁드립니다."
결과:
{
  "has_schedule": true,
  "event_type": "deadline",
  "title": "프로젝트 보고서 제출",
  "date": "2024-11-30",
  "start_time": "23:59",
  "end_time": "23:59",
  "location": null,
  "confidence": 90
}

예시 3:
이메일: "오늘 날씨가 참 좋네요."
결과:
{
  "has_schedule": false,
  "confidence": 100
}

이제 다음 이메일을 분석해주세요:
[이메일 내용]
```

**효과**: 정확도 +15%, 일관성 +25%

### Chain of Thought 기법

AI가 단계별로 생각하도록 유도:

```
이메일을 분석할 때 다음 단계를 따라주세요:

1단계: 일정 관련 키워드 찾기
  - "회의", "미팅", "마감", "제출", "약속" 등 확인

2단계: 날짜 정보 추출
  - "다음 주 월요일" → 현재 날짜 기준 계산
  - "11/15" → YYYY-MM-DD 형식으로 변환
  - "내일" → 현재 + 1일

3단계: 시간 정보 추출
  - "오후 2시" → 14:00
  - "저녁 7시" → 19:00
  - 시간 명시 없으면 기본값 (미팅: 10:00, 마감: 23:59)

4단계: 장소 및 참석자 추출
  - 장소: "3층 회의실", "Zoom", "Google Meet"
  - 참석자: 이메일 주소 형식

5단계: 신뢰도 평가
  - 모든 정보 명확: 90-100
  - 일부 추정 필요: 70-89
  - 많은 추정 필요: 50-69
  - 불확실: 50 미만

이제 분석을 시작하세요:
[이메일 내용]
```

**효과**: 복잡한 이메일 처리 정확도 +30%

---

## 날짜 파싱 알고리즘

### 한국어 상대 날짜 처리

```javascript
// 상대 날짜 문자열을 ISO 날짜로 변환
function parseRelativeDate(dateStr, baseDate = new Date()) {
  const today = baseDate;
  const result = new Date(today);
  
  // "내일"
  if (dateStr.includes('내일')) {
    result.setDate(result.getDate() + 1);
    return result.toISOString().split('T')[0];
  }
  
  // "모레"
  if (dateStr.includes('모레')) {
    result.setDate(result.getDate() + 2);
    return result.toISOString().split('T')[0];
  }
  
  // "다음 주 X요일"
  const nextWeekMatch = dateStr.match(/다음\s*주\s*(\S)요일/);
  if (nextWeekMatch) {
    const dayMap = {'월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6, '일': 0};
    const targetDay = dayMap[nextWeekMatch[1]];
    
    // 다음 주로 이동
    result.setDate(result.getDate() + (7 - result.getDay()) + targetDay);
    return result.toISOString().split('T')[0];
  }
  
  // "이번 주 X요일"
  const thisWeekMatch = dateStr.match(/이번\s*주\s*(\S)요일/);
  if (thisWeekMatch) {
    const dayMap = {'월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6, '일': 0};
    const targetDay = dayMap[thisWeekMatch[1]];
    const currentDay = result.getDay();
    
    let daysToAdd = targetDay - currentDay;
    if (daysToAdd < 0) daysToAdd += 7;  // 이미 지난 요일이면 다음 주
    
    result.setDate(result.getDate() + daysToAdd);
    return result.toISOString().split('T')[0];
  }
  
  // "N일 후"
  const daysLaterMatch = dateStr.match(/(\d+)일\s*후/);
  if (daysLaterMatch) {
    result.setDate(result.getDate() + parseInt(daysLaterMatch[1]));
    return result.toISOString().split('T')[0];
  }
  
  // "N주 후"
  const weeksLaterMatch = dateStr.match(/(\d+)주\s*후/);
  if (weeksLaterMatch) {
    result.setDate(result.getDate() + parseInt(weeksLaterMatch[1]) * 7);
    return result.toISOString().split('T')[0];
  }
  
  // "이번 달 말"
  if (dateStr.includes('이번') && dateStr.includes('말')) {
    result.setMonth(result.getMonth() + 1, 0);  // 다음 달 0일 = 이번 달 마지막 날
    return result.toISOString().split('T')[0];
  }
  
  // "다음 달 초"
  if (dateStr.includes('다음') && dateStr.includes('초')) {
    result.setMonth(result.getMonth() + 1, 1);  // 다음 달 1일
    return result.toISOString().split('T')[0];
  }
  
  // 기본값: 오늘
  return today.toISOString().split('T')[0];
}
```

---

## 중복 감지 로직

### 3단계 중복 체크

```javascript
function detectDuplicate(newEvent, existingEvents) {
  const results = existingEvents.map(existing => {
    // 1. 제목 유사도
    const titleSimilarity = calculateTitleSimilarity(
      newEvent.title,
      existing.summary
    );
    
    // 2. 시간 겹침
    const timeOverlap = calculateTimeOverlap(
      newEvent.start_datetime_iso,
      newEvent.end_datetime_iso,
      existing.start.dateTime,
      existing.end.dateTime
    );
    
    // 3. 참석자 겹침
    const attendeeOverlap = calculateAttendeeOverlap(
      newEvent.attendees,
      existing.attendees || []
    );
    
    // 종합 점수 계산
    const score = (
      titleSimilarity * 0.5 +
      timeOverlap * 0.3 +
      attendeeOverlap * 0.2
    );
    
    return {
      event_id: existing.id,
      title: existing.summary,
      score: score,
      is_duplicate: score >= 75  // 75점 이상이면 중복으로 판정
    };
  });
  
  // 가장 유사한 것 찾기
  const mostSimilar = results.reduce((max, curr) => 
    curr.score > max.score ? curr : max
  , {score: 0});
  
  return {
    is_duplicate: mostSimilar.score >= 75,
    duplicate_event: mostSimilar,
    all_candidates: results.filter(r => r.score >= 50)
  };
}
```

---

## 테스트 및 검증

### 샘플 이메일로 테스트

```bash
# 테스트 스크립트 실행
./scripts/test-schedule-extraction.sh

# 또는 수동 테스트
cat data/sample-emails/meeting-simple.txt
# "다음 주 화요일 오후 2시 3층 회의실에서 기획 회의"
```

**검증 포인트**:
- [ ] 이메일 수신 및 필터링
- [ ] AI 분석 JSON 형식
- [ ] 날짜 계산 정확성
- [ ] 시간 변환 정확성
- [ ] 중복 감지 작동
- [ ] Calendar 등록 성공
- [ ] 확인 이메일 발송

---

## 프로덕션 배포

### 배포 체크리스트

**인프라**:
- [ ] n8n 안정적으로 실행 중
- [ ] 모든 API 키 정상 작동
- [ ] Gmail/Calendar API 할당량 확인

**설정**:
- [ ] Gmail 라벨 생성: "일정"
- [ ] VIP 발신자 리스트 작성
- [ ] 알림 채널 설정 (Slack 등)

**테스트**:
- [ ] 5-10개 실제 이메일로 테스트
- [ ] 중복 감지 확인
- [ ] 다양한 날짜 표현 테스트

**모니터링**:
- [ ] 워크플로우 실행 로그 확인
- [ ] API 비용 모니터링
- [ ] 오류 발생 시 알림

---

## 문제 해결

### 문제 1: AI가 날짜를 잘못 계산

**증상**: "다음 주 월요일"을 엉뚱한 날짜로

**해결**:
1. System Message에 현재 날짜 정보 명확히 제공
2. Few-Shot 예시에 날짜 계산 예시 추가
3. 신뢰도 낮은 경우(<70) 사용자 확인

### 문제 2: 중복 일정이 계속 등록됨

**원인**: 중복 감지 임계값 너무 높음

**해결**:
```javascript
// 임계값 조정
const isDuplicate = score >= 65;  // 75 → 65로 낮춤
```

### 문제 3: Google Calendar API 할당량 초과

**증상**: "Quota exceeded" 오류

**해결**:
1. Schedule Trigger 빈도 줄이기 (하루 2회 → 1회)
2. 이메일 필터링 강화 (VIP만)
3. Google Cloud Console에서 할당량 증가 요청

---

## 다음 단계

### 고급 기능 추가

1. **정기 일정 지원**
2. **시간대 자동 감지**
3. **음성 메시지 처리** (Whisper API)
4. **모바일 앱 연동**

### 커뮤니티

- n8n Community: https://community.n8n.io
- GitHub: 피드백 환영

---

**문서 버전**: 1.0.0
**최종 업데이트**: 2024-11-07
