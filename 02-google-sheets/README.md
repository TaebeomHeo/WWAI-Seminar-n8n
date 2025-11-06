# 02. Google Sheets 연동

## 📚 학습 목표

- Google Sheets API 연동 방법 이해
- 데이터 읽기/쓰기/업데이트 작업 수행
- 실시간 데이터 동기화 구현
- 조건부 알림 시스템 구축

---

## 🔧 사전 준비

### Google Sheets API 인증 설정

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com 접속
   - 프로젝트 생성 또는 선택

2. **API 활성화**
   - "API 및 서비스" > "라이브러리" 이동
   - "Google Sheets API" 검색 및 활성화

3. **서비스 계정 생성**
   - "API 및 서비스" > "사용자 인증 정보"
   - "사용자 인증 정보 만들기" > "서비스 계정"
   - 서비스 계정 이름 입력 (예: n8n-automation)
   - JSON 키 파일 다운로드

4. **n8n에 인증 정보 추가**
   - n8n에서 "Credentials" 메뉴 이동
   - "Add Credential" > "Google Sheets API"
   - Service Account Email과 Private Key 입력

5. **Google Sheets 공유**
   - 작업할 Google Sheets를 서비스 계정 이메일과 공유
   - 편집자 권한 부여

---

## 🎯 실습 1: 매출 데이터 자동 기록 시스템

### 목표
Webhook으로 받은 매출 데이터를 Google Sheets에 자동으로 기록하고, 일정 금액 이상일 때 알림을 보냅니다.

### 사전 작업: Google Sheets 준비

1. 새 Google Sheets 생성
2. 시트 이름: `매출관리`
3. 첫 번째 행에 헤더 입력:

| A    | B      | C     | D    | E    |
|------|--------|-------|------|------|
| 날짜 | 고객명 | 상품  | 금액 | 상태 |

4. 서비스 계정과 공유

### 단계별 가이드

#### 1단계: 워크플로우 생성
- 이름: "02-Sales-Tracker"

#### 2단계: Webhook 노드 설정
```
HTTP Method: POST
Path: sales
Response Mode: lastNode
```

#### 3단계: Set 노드로 데이터 정리
받은 데이터를 Google Sheets에 맞게 정리합니다.

**Expression 예제:**
```javascript
// 날짜 필드
={{$now.toFormat('yyyy-MM-dd HH:mm:ss', 'Asia/Seoul')}}

// 고객명
={{$json.body.customer_name}}

// 상품
={{$json.body.product}}

// 금액 (숫자로 변환)
={{parseInt($json.body.amount)}}

// 상태
={{$json.body.status || "진행중"}}
```

#### 4단계: Google Sheets 노드 추가
1. "Google Sheets" 노드 검색 및 추가
2. 설정:
   - **Credential**: 앞서 만든 Google Sheets 인증 정보
   - **Operation**: `Append`
   - **Document**: Google Sheets URL 또는 ID
   - **Sheet**: `매출관리`
   - **Columns**: 자동 매핑 또는 수동 지정

**매핑 설정:**
- Column A → `={{$json.date}}`
- Column B → `={{$json.customer_name}}`
- Column C → `={{$json.product}}`
- Column D → `={{$json.amount}}`
- Column E → `={{$json.status}}`

#### 5단계: IF 노드로 조건 분기
10만원 이상 거래만 알림을 보냅니다.

```
Condition Type: Number
Value 1: ={{$json.amount}}
Operation: larger than or equal
Value 2: 100000
```

#### 6단계: Slack/Discord 알림 (선택사항)
True 분기에 알림 노드 추가

**Slack 메시지 예제:**
```
🎉 대형 거래 발생!

고객: {{$node["Set"].json["customer_name"]}}
상품: {{$node["Set"].json["product"]}}
금액: {{$node["Set"].json["amount"]}}원
시간: {{$node["Set"].json["date"]}}
```

#### 7단계: 응답 노드
```json
{
  "success": true,
  "message": "매출 데이터가 성공적으로 기록되었습니다",
  "data": "={{$node['Set'].json}}"
}
```

### 테스트

```bash
# data/test-sales-data.json 파일의 데이터로 테스트
curl -X POST YOUR_WEBHOOK_URL \
  -H "Content-Type: application/json" \
  -d @../data/test-sales-data.json
```

### 📝 실습 과제

**과제 1**: 중복 방지 로직 추가
- 같은 고객이 같은 시간대에 같은 상품을 주문한 경우 중복으로 판단
- Google Sheets Lookup 노드 사용

**과제 2**: 월별 합계 자동 계산
- 새로운 시트 `월별통계` 생성
- 매출이 추가될 때마다 월별 합계 업데이트

**과제 3**: 데이터 검증 강화
- 금액이 음수가 아닌지 확인
- 고객명이 2글자 이상인지 확인
- 필수 필드 누락 체크

---

## 🎯 실습 2: Google Sheets 데이터 읽기 및 분석

### 목표
Google Sheets의 고객 데이터를 읽어서 등급을 자동으로 계산하고 업데이트합니다.

### 사전 작업: 시트 구조

새 시트 `고객관리` 생성:

| A       | B      | C      | D    | E          |
|---------|--------|--------|------|------------|
| 고객ID  | 고객명 | 누적금액| 등급 | 업데이트일 |
| C001    | 홍길동 | 350000 |      |            |
| C002    | 김철수 | 150000 |      |            |
| C003    | 이영희 | 550000 |      |            |

### 단계별 가이드

#### 1단계: Schedule Trigger 설정
```
Trigger Times: 0 9 * * *  (매일 오전 9시)
또는 Manual Trigger로 수동 실행
```

#### 2단계: Google Sheets 읽기
```
Operation: Read
Document: 해당 Google Sheets
Sheet: 고객관리
Range: A2:E  (헤더 제외)
Header Row: Yes
```

#### 3단계: Code 노드로 등급 계산

```javascript
// 모든 고객 데이터 가져오기
const customers = $input.all();
const processedData = [];

// 각 고객별 등급 계산
for (const customer of customers) {
  const amount = parseInt(customer.json.누적금액 || 0);
  let grade = 'Bronze';

  // 등급 분류 로직
  if (amount >= 500000) {
    grade = 'Platinum';
  } else if (amount >= 300000) {
    grade = 'Gold';
  } else if (amount >= 100000) {
    grade = 'Silver';
  }

  processedData.push({
    고객ID: customer.json.고객ID,
    고객명: customer.json.고객명,
    누적금액: amount,
    등급: grade,
    업데이트일: new Date().toLocaleDateString('ko-KR')
  });
}

return processedData;
```

#### 4단계: Google Sheets 업데이트
```
Operation: Update
Document: 해당 Google Sheets
Sheet: 고객관리
Range: A2:E
Data: Code 노드의 출력 데이터
```

### 📝 실습 과제

**과제 1**: VIP 고객 자동 추출
- Platinum 등급 고객만 필터링
- 별도의 `VIP고객` 시트에 복사

**과제 2**: 등급 변경 알림
- 이전 등급과 현재 등급 비교
- 등급이 상승한 고객에게 축하 메시지 (이메일 또는 Slack)

**과제 3**: 통계 대시보드
- 등급별 고객 수 집계
- 등급별 평균 구매금액 계산
- `통계` 시트에 결과 저장

---

## 🎯 실습 3: 양방향 동기화 시스템

### 목표
Google Sheets의 변경사항을 감지하고 다른 시스템과 동기화합니다.

### 단계별 가이드

#### 1단계: Google Sheets Trigger 설정
```
Trigger Event: On Row Added
또는 Schedule Trigger + 마지막 업데이트 시간 체크
```

#### 2단계: 변경 감지 로직

```javascript
// 마지막 처리 시간 가져오기 (KV Store 또는 별도 시트 활용)
const lastProcessed = $node["Get Last Timestamp"].json.timestamp || "2024-01-01T00:00:00Z";
const currentData = $input.all();

// 새로운 데이터만 필터링
const newData = currentData.filter(item => {
  const itemDate = new Date(item.json.날짜);
  const lastDate = new Date(lastProcessed);
  return itemDate > lastDate;
});

return newData;
```

#### 3단계: 외부 API 호출 (예: CRM 시스템)

```
HTTP Request Node:
Method: POST
URL: https://your-crm-system.com/api/customers
Headers:
  Content-Type: application/json
  Authorization: Bearer YOUR_API_KEY
Body:
  {{$json}}
```

#### 4단계: 동기화 상태 업데이트
```
Google Sheets Update:
Column F: 동기화상태 → "완료"
Column G: 동기화시간 → current timestamp
```

---

## 📁 참고 자료

### data/ 폴더
- `test-sales-data.json` - 테스트용 매출 데이터
- `sample-customers.csv` - 샘플 고객 데이터
- `google-sheets-template.xlsx` - Google Sheets 템플릿

### solutions/ 폴더
- `01-sales-tracker.json` - 완성된 매출 추적 워크플로우
- `02-customer-grading.json` - 완성된 고객 등급 분류 워크플로우
- `03-sync-system.json` - 완성된 동기화 시스템

### scripts/ 폴더
- `test-sales-tracker.sh` - 매출 추적 테스트 스크립트
- `generate-test-data.js` - 대량 테스트 데이터 생성

---

## 💡 유용한 팁

### 1. Google Sheets 표현식

```javascript
// 특정 셀 참조
={{$json["A2"]}}

// 행 번호 얻기
={{$json["__rowNumber"]}}

// 여러 컬럼 합치기
={{$json.성 + $json.이름}}

// 날짜 포맷팅
={{$now.toFormat('yyyy-MM-dd', 'Asia/Seoul')}}
```

### 2. 성능 최적화

- **배치 처리**: 한 번에 여러 행 처리
- **Range 최소화**: 필요한 컬럼만 읽기
- **캐싱**: 자주 읽는 데이터는 n8n Static Data에 저장

### 3. 일반적인 오류

**오류 1**: "Insufficient permissions"
- 해결: 서비스 계정에 시트 편집 권한 부여

**오류 2**: "Range not found"
- 해결: 시트 이름과 Range 문법 확인 (예: `시트1!A1:E10`)

**오류 3**: "Unable to parse range"
- 해결: 한글 시트명은 작은따옴표로 감싸기 (예: `'매출관리'!A1:E`)

### 4. 보안 고려사항

- ✅ 서비스 계정 JSON 키를 안전하게 보관
- ✅ 필요한 시트만 공유
- ✅ 읽기 전용이 가능한 경우 읽기 권한만 부여
- ❌ 공개 링크로 시트를 공유하지 않기

---

## ✅ 완료 체크리스트

- [ ] Google Sheets API 인증 설정 완료
- [ ] 매출 데이터 자동 기록 시스템 구현
- [ ] 조건부 알림 시스템 작동 확인
- [ ] 고객 등급 자동 계산 및 업데이트 구현
- [ ] 데이터 읽기/쓰기/업데이트 모든 작업 테스트
- [ ] 모든 실습 과제 완료

---

**이전 단계**: [01. n8n 기초](../01-basics/README.md)
**다음 단계**: [03. 웹 스크래핑](../03-web-scraping/README.md)
