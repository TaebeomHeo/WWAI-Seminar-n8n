# 고급: 실전 웹 스크래핑 기법

실제 웹사이트에서 데이터를 수집하는 고급 기법과 우회 방법을 배웁니다.

---

## 🌐 JavaScript 렌더링 사이트 스크래핑

많은 최신 웹사이트는 JavaScript로 콘텐츠를 동적으로 로드합니다. 일반 HTTP Request로는 데이터를 가져올 수 없습니다.

### 방법 1: API 엔드포인트 직접 호출

대부분의 웹사이트는 브라우저에서 API를 호출하여 데이터를 가져옵니다.

#### 단계별 가이드

1. **브라우저 개발자 도구 열기 (F12)**
2. **Network 탭으로 이동**
3. **페이지 새로고침**
4. **XHR 또는 Fetch 필터 적용**
5. **실제 데이터를 가져오는 API 요청 찾기**

#### 실습 예제: 온라인 쇼핑몰

```javascript
// 브라우저에서 찾은 API
// https://api.example-shop.com/products?category=electronics&page=1

// n8n HTTP Request 노드 설정
{
  "method": "GET",
  "url": "https://api.example-shop.com/products",
  "qs": {
    "category": "electronics",
    "page": 1,
    "limit": 50
  },
  "headers": {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Referer": "https://example-shop.com/category/electronics",
    "Accept": "application/json"
  }
}
```

#### Code 노드로 데이터 파싱

```javascript
const response = $json;
const products = response.data.items || [];

return products.map(product => ({
  id: product.id,
  name: product.name,
  price: product.price,
  original_price: product.originalPrice,
  discount: product.discount,
  rating: product.rating,
  reviews_count: product.reviewsCount,
  in_stock: product.stock > 0,
  image_url: product.imageUrl,
  product_url: `https://example-shop.com/product/${product.id}`,
  scraped_at: new Date().toISOString()
}));
```

### 방법 2: Puppeteer/Browserless 사용

JavaScript 렌더링이 필요한 경우 헤드리스 브라우저를 사용합니다.

#### Browserless.io 활용

1. **Browserless 계정 생성**: https://browserless.io
2. **API 키 발급**
3. **n8n에서 HTTP Request로 호출**

```javascript
// HTTP Request 노드 설정
{
  "method": "POST",
  "url": "https://chrome.browserless.io/content?token=YOUR_API_KEY",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "url": "https://example.com/products",
    "waitFor": ".product-list",  // 이 요소가 로드될 때까지 대기
    "gotoOptions": {
      "waitUntil": "networkidle2"
    }
  }
}
```

#### Code 노드로 HTML 파싱

```javascript
const cheerio = require('cheerio');
const html = $json.data;
const $ = cheerio.load(html);

const products = [];

$('.product-item').each((i, elem) => {
  products.push({
    name: $(elem).find('.product-name').text().trim(),
    price: $(elem).find('.product-price').text().trim(),
    link: $(elem).find('a').attr('href')
  });
});

return products;
```

### 방법 3: Selenium Grid (Self-hosted)

완전한 제어가 필요한 경우 Selenium Grid를 사용합니다.

```javascript
// HTTP Request to Selenium Grid
{
  "method": "POST",
  "url": "http://selenium-hub:4444/wd/hub/session",
  "body": {
    "desiredCapabilities": {
      "browserName": "chrome",
      "chromeOptions": {
        "args": ["--headless", "--no-sandbox"]
      }
    }
  }
}
```

---

## 🚫 봇 탐지 우회 기법

### 1. User-Agent 로테이션

```javascript
// Code 노드에서 랜덤 User-Agent 선택
const userAgents = [
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
];

const randomUA = userAgents[Math.floor(Math.random() * userAgents.length)];

return {
  userAgent: randomUA
};

// 다음 HTTP Request 노드에서 사용
// Headers: User-Agent = {{$json.userAgent}}
```

### 2. 프록시 사용

```javascript
// HTTP Request 노드에서 프록시 설정
{
  "proxy": "http://proxy-server:8080",
  "headers": {
    "Proxy-Authorization": "Basic " + Buffer.from("username:password").toString('base64')
  }
}
```

### 3. 요청 간격 추가 (Rate Limiting)

```javascript
// Code 노드에서 딜레이 추가
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// 각 요청 사이에 2-5초 랜덤 대기
const waitTime = Math.floor(Math.random() * 3000) + 2000;
await delay(waitTime);

return $input.all();
```

### 4. Session & Cookies 유지

```javascript
// 첫 번째 요청에서 쿠키 받기
const firstResponse = await $http.get({
  url: 'https://example.com',
  resolveWithFullResponse: true
});

const cookies = firstResponse.headers['set-cookie'];

// 이후 요청에서 쿠키 사용
const secondResponse = await $http.get({
  url: 'https://example.com/data',
  headers: {
    'Cookie': cookies.join('; ')
  }
});
```

---

## 📄 페이지네이션 처리

### 방법 1: URL 기반 페이지네이션

```javascript
// Code 노드: 페이지 URL 생성
const totalPages = 10;
const urls = [];

for (let page = 1; page <= totalPages; page++) {
  urls.push({
    url: `https://example.com/products?page=${page}`,
    page: page
  });
}

return urls;

// Loop 노드로 각 URL 처리
```

### 방법 2: "Load More" 버튼 (무한 스크롤)

Browserless를 사용하여 버튼 클릭:

```javascript
{
  "url": "https://example.com/products",
  "evaluate": `
    async () => {
      let previousHeight = 0;
      let currentHeight = document.body.scrollHeight;

      while (previousHeight !== currentHeight) {
        previousHeight = currentHeight;

        // 페이지 끝까지 스크롤
        window.scrollTo(0, document.body.scrollHeight);

        // 새 콘텐츠 로드 대기
        await new Promise(resolve => setTimeout(resolve, 2000));

        currentHeight = document.body.scrollHeight;
      }

      return document.body.innerHTML;
    }
  `
}
```

### 방법 3: API 페이지네이션

```javascript
// Code 노드: 모든 페이지 데이터 수집
const allData = [];
let page = 1;
let hasMore = true;

while (hasMore) {
  const response = await $http.get({
    url: `https://api.example.com/products?page=${page}&limit=100`
  });

  allData.push(...response.data);

  // 다음 페이지가 있는지 확인
  hasMore = response.data.length === 100;
  page++;

  // Rate limiting
  if (hasMore) {
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}

return allData;
```

---

## 🔐 인증이 필요한 사이트 스크래핑

### 방법 1: 로그인 후 쿠키 사용

```javascript
// Step 1: 로그인 (HTTP Request POST)
const loginResponse = await $http.post({
  url: 'https://example.com/login',
  body: {
    username: 'your-username',
    password: 'your-password'
  },
  resolveWithFullResponse: true
});

const cookies = loginResponse.headers['set-cookie'];
const sessionCookie = cookies.find(c => c.startsWith('session='));

// Step 2: 쿠키로 데이터 요청
const dataResponse = await $http.get({
  url: 'https://example.com/protected-data',
  headers: {
    'Cookie': sessionCookie
  }
});

return dataResponse;
```

### 방법 2: Bearer Token 인증

```javascript
// Step 1: 토큰 발급
const authResponse = await $http.post({
  url: 'https://api.example.com/auth/token',
  body: {
    client_id: 'your-client-id',
    client_secret: 'your-client-secret'
  }
});

const accessToken = authResponse.access_token;

// Step 2: 토큰으로 API 호출
const data = await $http.get({
  url: 'https://api.example.com/data',
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});

return data;
```

---

## 📊 실전 프로젝트: 부동산 매물 모니터링

### 목표
부동산 사이트에서 특정 조건의 매물을 주기적으로 수집하여 새로운 매물이 나오면 알림

### 워크플로우 구성

1. **Schedule Trigger** - 1시간마다
2. **HTTP Request** - 매물 검색 API 호출
3. **Code** - 데이터 파싱 및 정제
4. **Google Sheets Lookup** - 기존 매물인지 확인
5. **IF** - 새로운 매물인가?
6. **Google Sheets Append** - 새 매물 저장
7. **Slack/Email** - 알림 발송

### 상세 구현

```javascript
// HTTP Request 노드
{
  "method": "POST",
  "url": "https://api.realestate-example.com/search",
  "body": {
    "region": "서울특별시 강남구",
    "dealType": "매매",
    "propertyType": "아파트",
    "priceMin": 500000000,
    "priceMax": 1000000000,
    "areaMin": 60,
    "areaMax": 100
  }
}

// Code 노드: 데이터 정제
const listings = $json.data.items || [];

return listings.map(item => ({
  id: item.id,
  title: item.title,
  price: item.price,
  area: item.area,
  floor: item.floor,
  direction: item.direction,
  built_year: item.builtYear,
  address: item.address,
  agent_name: item.agentName,
  agent_phone: item.agentPhone,
  url: `https://realestate-example.com/listing/${item.id}`,
  posted_at: item.postedAt,
  scraped_at: new Date().toISOString()
}));

// Google Sheets Lookup으로 중복 확인
// IF 노드: $node["Google Sheets Lookup"].json.id가 없으면 새 매물

// Slack 알림
{
  "text": `🏡 새로운 매물 등록!

📍 위치: {{$json.address}}
💰 가격: {{$json.price}}원
📐 면적: {{$json.area}}㎡
🏢 층수: {{$json.floor}}층
📅 등록: {{$json.posted_at}}

🔗 상세보기: {{$json.url}}`
}
```

---

## 🛠️ 실전 도구 및 서비스

### 추천 프록시 서비스
- **Bright Data** (구 Luminati): https://brightdata.com
- **Oxylabs**: https://oxylabs.io
- **ScraperAPI**: https://scraperapi.com

### 헤드리스 브라우저 서비스
- **Browserless**: https://browserless.io
- **Apify**: https://apify.com
- **Selenium Grid**: Self-hosted

### 스크래핑 도우미 도구
- **SelectorGadget**: Chrome 확장 프로그램
- **Postman**: API 테스트
- **curl converter**: curl 명령어를 코드로 변환

---

## 📁 제공 파일

### workflows/
- `api-scraping.json` - API 엔드포인트 직접 호출
- `browserless-scraping.json` - Browserless로 JS 렌더링
- `pagination-handling.json` - 페이지네이션 처리
- `real-estate-monitor.json` - 부동산 매물 모니터링

### scripts/
- `find-api-endpoints.js` - HAR 파일에서 API 자동 추출
- `test-proxy.py` - 프록시 연결 테스트
- `session-manager.js` - 세션/쿠키 관리

---

## ⚠️ 법적 유의사항

1. **robots.txt 준수**: 항상 확인
2. **이용약관 검토**: 스크래핑 금지 조항 확인
3. **공개 데이터만**: 로그인 필요한 개인정보 수집 금지
4. **적절한 간격**: 서버에 부하를 주지 않기
5. **상업적 이용 주의**: 저작권 침해 가능성

---

**다음 단계**: 수집한 데이터를 AI로 분석 → [04-ai-automation/advanced](../../04-ai-automation/advanced/README.md)
