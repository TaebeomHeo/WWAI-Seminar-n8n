# 고급: 실제 데이터 수집 방법

이 섹션에서는 실제 서비스에서 데이터를 수집하여 n8n 워크플로우에서 사용하는 방법을 배웁니다.

---

## 📧 Gmail에서 이메일 데이터 수집하기

### 사전 준비

1. **Gmail API 활성화**
   - Google Cloud Console: https://console.cloud.google.com
   - "API 및 서비스" > "라이브러리"
   - "Gmail API" 검색 및 활성화

2. **OAuth 2.0 인증 정보 생성**
   - "API 및 서비스" > "사용자 인증 정보"
   - "사용자 인증 정보 만들기" > "OAuth 클라이언트 ID"
   - 애플리케이션 유형: "웹 애플리케이션"
   - 승인된 리디렉션 URI 추가:
     - n8n Cloud: `https://app.n8n.cloud/rest/oauth2-credential/callback`
     - Self-hosted: `http://localhost:5678/rest/oauth2-credential/callback`
   - Client ID와 Client Secret 저장

3. **n8n에 Gmail 인증 추가**
   - n8n → Credentials → "Add Credential"
   - "Gmail OAuth2" 선택
   - Client ID와 Client Secret 입력
   - "Connect my account" 클릭하여 구글 계정 연동

### 워크플로우 1: 최근 이메일 가져오기

**목적**: 최근 10개의 이메일을 가져와서 Google Sheets에 저장

#### 노드 구성

1. **Manual Trigger** 또는 **Schedule Trigger**
2. **Gmail** 노드
   ```
   Resource: Message
   Operation: Get All
   Return All: false
   Limit: 10
   Filters:
     - Label: INBOX
     - Is Unread: Optional
   ```

3. **Code** 노드 - 데이터 정리
   ```javascript
   const emails = $input.all();
   const processed = [];

   for (const email of emails) {
     const data = email.json;

     // 헤더에서 정보 추출
     const getHeader = (headers, name) => {
       const header = headers.find(h => h.name.toLowerCase() === name.toLowerCase());
       return header ? header.value : '';
     };

     processed.push({
       id: data.id,
       threadId: data.threadId,
       from: getHeader(data.payload.headers, 'From'),
       to: getHeader(data.payload.headers, 'To'),
       subject: getHeader(data.payload.headers, 'Subject'),
       date: getHeader(data.payload.headers, 'Date'),
       snippet: data.snippet,
       labels: data.labelIds ? data.labelIds.join(', ') : '',
       received_at: new Date().toISOString()
     });
   }

   return processed;
   ```

4. **Google Sheets** 노드
   ```
   Operation: Append
   Document: [Your Sheet]
   Sheet: 이메일로그
   Columns: A-I (자동 매핑)
   ```

### 워크플로우 2: 특정 발신자 이메일 필터링

**목적**: 특정 발신자로부터 온 이메일만 수집

#### Gmail 검색 쿼리 활용

Gmail 노드의 Filter 설정:
```
Query: from:example@company.com after:2024/11/01
```

**유용한 Gmail 검색 쿼리:**
```
# 특정 발신자
from:user@example.com

# 제목 포함
subject:"invoice"

# 날짜 범위
after:2024/11/01 before:2024/11/30

# 첨부파일 있는 이메일
has:attachment

# 읽지 않은 이메일
is:unread

# 여러 조건 조합
from:billing@company.com has:attachment after:2024/11/01
```

### 워크플로우 3: 이메일 첨부파일 다운로드

**목적**: 이메일의 첨부파일을 Google Drive에 저장

#### 노드 구성

1. **Gmail Trigger** (또는 Schedule + Gmail Get All)
2. **Code** 노드 - 첨부파일 추출
   ```javascript
   const email = $json;
   const attachments = [];

   function extractAttachments(parts) {
     if (!parts) return;

     for (const part of parts) {
       if (part.filename && part.body && part.body.attachmentId) {
         attachments.push({
           filename: part.filename,
           mimeType: part.mimeType,
           attachmentId: part.body.attachmentId
         });
       }

       if (part.parts) {
         extractAttachments(part.parts);
       }
     }
   }

   extractAttachments(email.payload.parts);

   return attachments.map(att => ({
     ...email,
     attachment: att
   }));
   ```

3. **Gmail** 노드 (각 첨부파일마다)
   ```
   Resource: Message
   Operation: Get Attachment
   Message ID: {{$json.id}}
   Attachment ID: {{$json.attachment.attachmentId}}
   ```

4. **Google Drive** 노드
   ```
   Operation: Upload
   File Name: {{$json.attachment.filename}}
   Parents: [Your Folder ID]
   Binary Data: true
   ```

---

## 📊 Google Analytics 데이터 수집

### 사전 준비

1. **Google Analytics API 활성화**
   - Google Cloud Console에서 "Google Analytics Data API" 활성화

2. **서비스 계정 생성 및 권한 부여**
   - 서비스 계정 생성
   - Google Analytics에서 해당 서비스 계정에 "뷰어" 권한 부여

3. **Property ID 확인**
   - Google Analytics → 관리 → 속성 설정
   - Property ID 복사 (예: 123456789)

### 워크플로우: 일일 트래픽 데이터 수집

#### 노드 구성

1. **Schedule Trigger**
   ```
   Cron: 0 9 * * * (매일 오전 9시)
   ```

2. **HTTP Request** 노드
   ```
   Method: POST
   URL: https://analyticsdata.googleapis.com/v1beta/properties/YOUR_PROPERTY_ID:runReport
   Authentication: OAuth2 (Google)

   Headers:
     Content-Type: application/json

   Body (JSON):
   {
     "dateRanges": [{
       "startDate": "yesterday",
       "endDate": "yesterday"
     }],
     "dimensions": [
       {"name": "date"},
       {"name": "country"},
       {"name": "deviceCategory"}
     ],
     "metrics": [
       {"name": "sessions"},
       {"name": "totalUsers"},
       {"name": "screenPageViews"},
       {"name": "conversions"}
     ]
   }
   ```

3. **Code** 노드 - 데이터 정리
   ```javascript
   const response = $json;
   const rows = response.rows || [];
   const processed = [];

   for (const row of rows) {
     processed.push({
       date: row.dimensionValues[0].value,
       country: row.dimensionValues[1].value,
       device: row.dimensionValues[2].value,
       sessions: parseInt(row.metricValues[0].value),
       users: parseInt(row.metricValues[1].value),
       pageviews: parseInt(row.metricValues[2].value),
       conversions: parseFloat(row.metricValues[3].value),
       collected_at: new Date().toISOString()
     });
   }

   return processed;
   ```

4. **Google Sheets** 노드
   ```
   Operation: Append
   Sheet: GA_트래픽
   ```

---

## 🗄️ CRM/Database에서 데이터 가져오기

### MySQL/PostgreSQL 연결

#### 사전 준비
1. 데이터베이스 접속 정보 확인
2. n8n에서 DB Credential 추가

#### 워크플로우: 고객 데이터 동기화

1. **Schedule Trigger**
2. **PostgreSQL** (또는 MySQL) 노드
   ```sql
   Operation: Execute Query
   Query:
   SELECT
     customer_id,
     name,
     email,
     total_purchases,
     last_purchase_date,
     created_at
   FROM customers
   WHERE updated_at >= NOW() - INTERVAL '24 hours'
   ORDER BY updated_at DESC
   ```

3. **Code** 노드 - 데이터 변환
4. **Google Sheets** 노드 - 업데이트

### REST API에서 데이터 가져오기

#### 일반적인 패턴

```javascript
// HTTP Request 노드 설정
Method: GET
URL: https://api.yourcrm.com/customers
Authentication: API Key / Bearer Token

Headers:
  Authorization: Bearer YOUR_API_TOKEN
  Content-Type: application/json

// 페이지네이션 처리 (Code 노드)
const allData = [];
let page = 1;
let hasMore = true;

while (hasMore) {
  const response = await $http.get({
    url: `https://api.yourcrm.com/customers?page=${page}&limit=100`,
    headers: {
      'Authorization': 'Bearer YOUR_TOKEN'
    }
  });

  allData.push(...response.data);
  hasMore = response.data.length === 100;
  page++;
}

return allData;
```

---

## 💡 실전 팁

### 1. API 한도 관리

```javascript
// Rate Limiting 처리
const REQUESTS_PER_MINUTE = 60;
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

for (let i = 0; i < items.length; i++) {
  // 처리
  await processItem(items[i]);

  // 1분에 60개 제한
  if ((i + 1) % REQUESTS_PER_MINUTE === 0) {
    await delay(60000); // 1분 대기
  }
}
```

### 2. 에러 핸들링 및 재시도

```javascript
async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      return response;
    } catch (error) {
      if (i === maxRetries - 1) throw error;

      // 지수 백오프
      const waitTime = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
}
```

### 3. 증분 동기화 (Incremental Sync)

```javascript
// 마지막 동기화 시간 저장 (Google Sheets 또는 n8n Static Data)
const lastSyncTime = $node["Get Last Sync Time"].json.timestamp || "2024-01-01T00:00:00Z";

// 새로운 데이터만 가져오기
const newData = await fetchData({
  updatedAfter: lastSyncTime
});

// 현재 시간을 다음 동기화를 위해 저장
const currentTime = new Date().toISOString();
await saveLastSyncTime(currentTime);
```

---

## 📁 제공 파일

### workflows/
- `gmail-to-sheets.json` - Gmail 이메일을 Sheets에 저장
- `gmail-attachment-download.json` - 첨부파일 다운로드
- `google-analytics-daily.json` - GA 일일 데이터 수집
- `database-sync.json` - DB 데이터 동기화

### scripts/
- `test-gmail-api.py` - Gmail API 테스트 스크립트
- `test-analytics-api.js` - Analytics API 테스트

---

## 🆘 문제 해결

### Gmail API 오류

**오류**: "Insufficient Permission"
```
해결:
1. OAuth 동의 화면에서 필요한 Scope 추가
2. Gmail API 권한 재인증
3. n8n Credential 재연결
```

**오류**: "Rate Limit Exceeded"
```
해결:
1. Wait 노드로 요청 간격 추가
2. Batch 크기 줄이기
3. 여러 서비스 계정 로테이션
```

### Google Analytics API 오류

**오류**: "Property not found"
```
해결:
1. Property ID 확인
2. 서비스 계정에 GA 뷰어 권한 부여
3. GA4 속성 ID 사용 (UA가 아님)
```

---

**다음 단계**: 수집한 데이터를 AI로 분석하기 → [04-ai-automation](../../04-ai-automation/README.md)
