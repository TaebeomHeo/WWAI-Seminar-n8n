# CSS 선택자 치트시트

## 기본 선택자

| 선택자 | 설명 | 예제 |
|--------|------|------|
| `.class` | 클래스 이름으로 선택 | `.price-current` |
| `#id` | ID로 선택 | `#product-price` |
| `element` | HTML 요소로 선택 | `h1`, `div`, `span` |
| `*` | 모든 요소 선택 | `*` |

## 속성 선택자

| 선택자 | 설명 | 예제 |
|--------|------|------|
| `[attribute]` | 특정 속성을 가진 요소 | `[data-price]` |
| `[attribute="value"]` | 속성 값이 일치하는 요소 | `[data-product-id="101"]` |
| `[attribute^="value"]` | 속성 값이 특정 문자로 시작 | `[class^="price"]` |
| `[attribute$="value"]` | 속성 값이 특정 문자로 끝남 | `[class$="current"]` |
| `[attribute*="value"]` | 속성 값에 특정 문자 포함 | `[class*="price"]` |

## 조합 선택자

| 선택자 | 설명 | 예제 |
|--------|------|------|
| `A B` | A의 모든 하위 B 요소 | `.product .price` |
| `A > B` | A의 직계 자식 B 요소 | `.product > .price` |
| `A + B` | A 바로 다음에 오는 B 요소 | `h1 + p` |
| `A ~ B` | A 이후의 모든 형제 B 요소 | `h1 ~ p` |

## 가상 클래스

| 선택자 | 설명 | 예제 |
|--------|------|------|
| `:first-child` | 첫 번째 자식 요소 | `.product-item:first-child` |
| `:last-child` | 마지막 자식 요소 | `.product-item:last-child` |
| `:nth-child(n)` | n번째 자식 요소 | `.product-item:nth-child(2)` |
| `:not(selector)` | 특정 선택자가 아닌 요소 | `.item:not(.disabled)` |

## 실전 예제

### 1. 가격 추출
```javascript
// 현재 가격
.price-current

// 원래 가격
.price-original

// 할인율
.discount
```

### 2. 제품 정보
```javascript
// 제품명
h1.product-title

// 설명
.product-description

// 재고 상태
.stock-status
```

### 3. 리스트 아이템
```javascript
// 모든 제품 아이템
.product-item

// 각 아이템의 이름
.product-item .product-name

// 각 아이템의 가격
.product-item .product-price

// 특정 ID를 가진 제품
.product-item[data-product-id="101"]
```

### 4. 복잡한 선택
```javascript
// 재고가 있는 제품의 가격
.product:has(.stock-status:contains("재고있음")) .price-current

// 첫 번째 관련 제품의 이름
.related-products .product-item:first-child .product-name

// 평점이 4.0 이상인 제품
.product[data-rating^="4."], .product[data-rating^="5."]
```

## n8n에서 사용하기

### HTML Extract 노드
```json
{
  "title": "h1.product-title",
  "price": ".price-current",
  "description": ".product-description",
  "rating": ".rating-value"
}
```

### Code 노드 (Cheerio)
```javascript
const cheerio = require('cheerio');
const html = $input.first().json.data;
const $ = cheerio.load(html);

// 단일 요소
const title = $('h1.product-title').text().trim();

// 여러 요소
const relatedProducts = [];
$('.product-item').each((i, elem) => {
  relatedProducts.push({
    name: $(elem).find('.product-name').text().trim(),
    price: $(elem).find('.product-price').text().trim()
  });
});

return { title, relatedProducts };
```

## 디버깅 팁

### 브라우저 콘솔에서 테스트
```javascript
// 단일 요소
document.querySelector('.price-current')

// 여러 요소
document.querySelectorAll('.product-item')

// 존재 여부 확인
document.querySelector('.price-current') !== null
```

### 선택자 검증 사이트
- https://try.jsoup.org/
- https://www.freeformatter.com/xpath-tester.html
- Chrome DevTools Elements 탭

## 주의사항

1. **클래스명 변경**: 웹사이트가 업데이트되면 클래스명이 변경될 수 있음
2. **동적 콘텐츠**: JavaScript로 로드되는 콘텐츠는 일반 HTML 요청으로 가져올 수 없음
3. **구조 변경**: HTML 구조가 변경되면 선택자도 수정 필요
4. **공백 처리**: `.trim()` 사용하여 불필요한 공백 제거
