# 03. 웹 스크래핑 및 데이터 처리

## 📚 학습 목표

- HTTP Request 노드를 사용한 웹 데이터 수집
- HTML 파싱 및 데이터 추출
- 정기적인 모니터링 시스템 구축
- 가격 변동 감지 및 알림

---

## ⚠️ 웹 스크래핑 윤리 및 법적 고려사항

웹 스크래핑을 시작하기 전에 반드시 확인해야 할 사항:

1. **robots.txt 확인**: `사이트주소/robots.txt`에서 크롤링 허용 여부 확인
2. **이용약관 검토**: 해당 웹사이트의 서비스 이용약관 확인
3. **접속 빈도 제한**: 과도한 요청으로 서버에 부하를 주지 않기 (최소 1-5초 간격)
4. **공개 API 우선**: 가능하면 공식 API 사용
5. **개인정보 주의**: 개인정보나 저작권 보호 콘텐츠 수집 금지

---

## 🎯 실습 1: 기본 웹 스크래핑

### 목표
간단한 웹페이지에서 데이터를 추출하는 기본 워크플로우를 만듭니다.

### 단계별 가이드

#### 1단계: Manual Trigger 또는 Schedule Trigger
```
Manual Trigger: 수동 실행으로 테스트
또는
Schedule Trigger: 0 */6 * * * (6시간마다)
```

#### 2단계: HTTP Request 노드 추가
```
Method: GET
URL: https://example.com
Authentication: None
Options:
  - Redirect: Follow All Redirects
  - Response Format: String (HTML 응답)
  - Timeout: 30000 (30초)
  - User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
```

**중요**: User-Agent를 설정하면 일부 웹사이트에서 봇 차단을 우회할 수 있습니다.

#### 3단계: HTML Extract 노드
n8n의 HTML Extract 노드를 사용하여 원하는 데이터 추출

```javascript
// CSS Selector 예제
{
  "title": "h1.product-title",
  "price": ".price-current",
  "description": ".product-description",
  "rating": ".rating-value"
}
```

또는 Code 노드로 직접 파싱:

```javascript
// cheerio 라이브러리 사용
const cheerio = require('cheerio');
const html = $input.first().json.data;
const $ = cheerio.load(html);

const result = {
  title: $('h1.product-title').text().trim(),
  price: $('.price-current').text().trim(),
  description: $('.product-description').text().trim(),
  rating: $('.rating-value').text().trim(),
  crawled_at: new Date().toISOString()
};

return result;
```

#### 4단계: 데이터 정제 (Code 노드)
추출한 데이터를 정제하고 표준화합니다.

```javascript
const data = $json;

// 가격에서 숫자만 추출
const priceText = data.price || "0";
const price = parseInt(priceText.replace(/[^0-9]/g, ''));

// 제목 정리
const title = data.title.trim().replace(/\s+/g, ' ');

// 재고 상태 표준화
const availability = data.availability?.includes('재고') ? '재고있음' : '품절';

return {
  product_name: title,
  price: price,
  availability: availability,
  rating: parseFloat(data.rating) || 0,
  description: data.description?.substring(0, 200), // 200자로 제한
  crawled_at: new Date().toISOString(),
  source_url: $('HTTP Request').first().json.url
};
```

#### 5단계: Google Sheets에 저장
추출한 데이터를 Google Sheets에 저장합니다.

```
Operation: Append
Sheet: 제품모니터링
Columns: A(제품명), B(가격), C(재고상태), D(평점), E(수집시간)
```

### 📝 실습 과제

**과제 1**: 여러 페이지 크롤링
- 제품 목록 페이지에서 모든 제품 URL 수집
- 각 URL을 순회하며 상세 정보 크롤링
- Loop 노드 또는 Split In Batches 노드 활용

**과제 2**: 이미지 URL 수집
- 제품 이미지 URL 추출
- (선택) HTTP Request로 이미지 다운로드 및 저장

**과제 3**: 에러 핸들링
- 페이지 로드 실패 시 재시도
- 특정 요소가 없을 때 기본값 설정

---

## 🎯 실습 2: 경쟁사 가격 모니터링 시스템

### 목표
경쟁사 웹사이트의 제품 가격을 주기적으로 수집하여 변동사항을 감지하고 알림을 보냅니다.

### 사전 준비

1. **Google Sheets 생성**: `가격모니터링` 시트
2. **헤더 설정**:

| A        | B      | C      | D        | E          | F        |
|----------|--------|--------|----------|------------|----------|
| 제품명   | 현재가격| 이전가격| 변동률   | 수집시간   | 상태     |

### 단계별 가이드

#### 1단계: 모니터링 대상 URL 관리

**방법 1**: Google Sheets에서 URL 목록 관리
```
Sheet: 모니터링URL
Columns: 제품명, URL, CSS선택자
```

**방법 2**: Code 노드에 하드코딩
```javascript
const targets = [
  {
    name: "경쟁사A 스마트폰",
    url: "https://competitor-a.com/products/smartphone",
    selectors: {
      price: ".price-current",
      availability: ".stock-status"
    }
  },
  {
    name: "경쟁사B 노트북",
    url: "https://competitor-b.com/products/laptop",
    selectors: {
      price: "#product-price",
      availability: ".availability"
    }
  }
];

return targets;
```

#### 2단계: Schedule Trigger 설정
```
Cron Expression: 0 */6 * * *
Description: 6시간마다 실행
```

#### 3단계: Loop 노드로 각 URL 처리
Split In Batches 노드 추가:
```
Batch Size: 1
Options: Reset (각 아이템을 개별 처리)
```

#### 4단계: HTTP Request + 데이터 추출
```javascript
// Code 노드에서 이전 단계의 URL 사용
const target = $json;
const cheerio = require('cheerio');

// HTTP Request는 별도 노드로 실행 (Code 노드 전)
const html = $node["HTTP Request"].json.data;
const $ = cheerio.load(html);

// 선택자를 사용해 데이터 추출
const currentPrice = $(target.selectors.price).text().trim();
const availability = $(target.selectors.availability).text().trim();

// 가격 정제
const price = parseInt(currentPrice.replace(/[^0-9]/g, ''));

return {
  product_name: target.name,
  current_price: price,
  availability: availability.includes('재고') ? '재고있음' : '품절',
  crawled_at: new Date().toISOString(),
  source_url: target.url
};
```

#### 5단계: 이전 가격 조회 (Google Sheets Lookup)
```
Operation: Lookup
Lookup Column: A (제품명)
Lookup Value: ={{$json.product_name}}
```

#### 6단계: 가격 변동 계산 및 감지

```javascript
const currentData = $json;
const previousData = $node["Google Sheets Lookup"].json;

// 이전 데이터가 없으면 첫 수집
if (!previousData || !previousData.이전가격) {
  return {
    ...currentData,
    previous_price: null,
    change_amount: 0,
    change_percent: 0,
    status: '신규등록',
    alert: false
  };
}

const previousPrice = parseInt(previousData.이전가격);
const currentPrice = currentData.current_price;

// 변동 계산
const changeAmount = currentPrice - previousPrice;
const changePercent = ((changeAmount / previousPrice) * 100).toFixed(2);

// 5% 이상 변동 시 알림
const shouldAlert = Math.abs(changePercent) >= 5;

return {
  ...currentData,
  previous_price: previousPrice,
  change_amount: changeAmount,
  change_percent: parseFloat(changePercent),
  status: changeAmount > 0 ? '가격인상' : changeAmount < 0 ? '가격인하' : '변동없음',
  alert: shouldAlert
};
```

#### 7단계: IF 노드로 알림 분기
```
Condition: ={{$json.alert}} equals true
```

#### 8단계: 알림 발송 (True 분기)

**Slack 알림 예제:**
```
💰 가격 변동 알림

📦 제품: {{$json.product_name}}
💵 이전 가격: {{$json.previous_price}}원
💵 현재 가격: {{$json.current_price}}원
📊 변동: {{$json.change_amount}}원 ({{$json.change_percent}}%)
📈 상태: {{$json.status}}
🕐 시간: {{$json.crawled_at}}
🔗 URL: {{$json.source_url}}
```

#### 9단계: Google Sheets 업데이트 (모든 분기)
```
Operation: Update
Match Column: A (제품명)
Data to Update: 모든 필드
```

### 📝 실습 과제

**과제 1**: 가격 히스토리 추적
- 별도의 `가격히스토리` 시트 생성
- 모든 가격 변동 이력 저장 (Append 방식)

**과제 2**: 가격 트렌드 분석
- 최근 30일간 가격 변동 추이 계산
- 평균 가격, 최고가, 최저가 집계

**과제 3**: 다중 알림 채널
- 가격 인하 시 → Slack 알림
- 가격 인상 시 → 이메일 알림
- 품절 시 → SMS 알림 (Twilio 등)

---

## 🎯 실습 3: 동적 콘텐츠 스크래핑 (고급)

### 목표
JavaScript로 렌더링되는 동적 웹페이지에서 데이터를 추출합니다.

### 배경
일부 웹사이트는 JavaScript를 통해 콘텐츠를 동적으로 로드합니다. 이 경우 일반 HTTP Request로는 데이터를 가져올 수 없습니다.

### 해결 방법

#### 방법 1: API 엔드포인트 직접 호출
브라우저 개발자 도구(F12) → Network 탭에서 실제 데이터를 가져오는 API 찾기

```
HTTP Request:
Method: GET
URL: https://api.example.com/products?page=1
Headers:
  Accept: application/json
  Referer: https://example.com
```

#### 방법 2: Browserless/Puppeteer 서비스 사용

**Browserless 노드 설정:**
```
URL: 대상 웹페이지
Wait For: .price-current (특정 요소가 로드될 때까지 대기)
Screenshot: Optional
HTML: Return HTML after JavaScript execution
```

#### 방법 3: 외부 스크래핑 서비스
- ScrapingBee
- Apify
- Bright Data

### 📝 실습 과제

**과제 1**: API 리버스 엔지니어링
- 브라우저 개발자 도구로 실제 API 엔드포인트 찾기
- 직접 API 호출하여 데이터 수집

**과제 2**: 페이지네이션 처리
- 여러 페이지에 걸쳐 있는 데이터 수집
- Loop 노드로 페이지 번호 증가시키며 크롤링

---

## 📁 참고 자료

### data/ 폴더
- `sample-html.html` - 연습용 HTML 파일
- `css-selectors.md` - CSS 선택자 치트시트
- `monitoring-urls.csv` - 모니터링 대상 URL 샘플

### solutions/ 폴더
- `01-basic-scraping.json` - 기본 스크래핑 워크플로우
- `02-price-monitoring.json` - 가격 모니터링 시스템
- `03-multi-page-scraping.json` - 다중 페이지 크롤링

### scripts/ 폴더
- `test-scraping.sh` - 스크래핑 테스트 스크립트
- `mock-server.js` - 로컬 테스트 서버 (연습용)

---

## 💡 유용한 팁

### 1. CSS 선택자 기본

```css
/* 클래스 */
.price-current

/* ID */
#product-price

/* 속성 */
[data-price]

/* 자식 요소 */
.product > .price

/* 하위 요소 */
.product .price

/* n번째 요소 */
.product:nth-child(2)

/* 텍스트 포함 */
:contains("재고")
```

### 2. 웹 스크래핑 디버깅

1. **브라우저 개발자 도구 활용**
   - F12 → Elements 탭에서 요소 검사
   - Console에서 `document.querySelector('.price')` 테스트

2. **n8n에서 HTML 확인**
   - HTTP Request 노드 실행 후 데이터 확인
   - HTML 구조 분석

3. **단계별 테스트**
   - 각 노드를 개별적으로 실행하여 데이터 확인
   - Execute Node 버튼 활용

### 3. 일반적인 문제 해결

**문제 1**: 403 Forbidden 또는 차단
```
해결:
- User-Agent 헤더 추가
- Referer 헤더 추가
- 요청 간 딜레이 추가 (Wait 노드)
```

**문제 2**: 요소를 찾을 수 없음
```
해결:
- CSS 선택자 확인
- JavaScript 렌더링 여부 확인
- 페이지 로드 대기 시간 증가
```

**문제 3**: 인코딩 문제 (한글 깨짐)
```
해결:
- Response Options에서 Encoding 설정 (UTF-8)
- HTML meta charset 확인
```

### 4. 성능 최적화

```javascript
// 배치 처리로 여러 URL 동시 크롤링
const urls = ['url1', 'url2', 'url3'];

// Split In Batches
Batch Size: 3
Options: Allow Execute Only Once

// Wait 노드로 딜레이 추가
Wait Time: 2000 (2초)
```

### 5. 데이터 정제 패턴

```javascript
// 가격 정제
const cleanPrice = (text) => {
  return parseInt(text.replace(/[^0-9]/g, '')) || 0;
};

// 공백 정리
const cleanText = (text) => {
  return text?.trim().replace(/\s+/g, ' ') || '';
};

// 날짜 파싱
const parseDate = (text) => {
  return new Date(text).toISOString();
};

// URL 정규화
const normalizeUrl = (url, baseUrl) => {
  return url.startsWith('http') ? url : new URL(url, baseUrl).href;
};
```

---

## ✅ 완료 체크리스트

- [ ] 기본 웹 스크래핑 워크플로우 작성 완료
- [ ] CSS 선택자를 사용한 데이터 추출 이해
- [ ] 경쟁사 가격 모니터링 시스템 구현 완료
- [ ] 가격 변동 감지 및 알림 기능 작동 확인
- [ ] 에러 핸들링 및 재시도 로직 구현
- [ ] 웹 스크래핑 윤리 및 법적 고려사항 이해
- [ ] 모든 실습 과제 완료

---

**이전 단계**: [02. Google Sheets 연동](../02-google-sheets/README.md)
**다음 단계**: [04. AI 자동화](../04-ai-automation/README.md)
