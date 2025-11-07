#!/usr/bin/env node

/**
 * Google Sheets 매출 추적 시스템 테스트 스크립트 (Node.js)
 * 사용법: node test-sales-tracker.js YOUR_WEBHOOK_URL
 */

const https = require('https');
const http = require('http');

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  yellow: '\x1b[33m'
};

const WEBHOOK_URL = process.argv[2] || 'https://your-n8n-instance.app.n8n.cloud/webhook/sales';

/**
 * HTTP POST 요청
 */
function makePostRequest(url, data) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;
    const postData = JSON.stringify(data);

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port,
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = protocol.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          resolve(JSON.parse(responseData));
        } catch (e) {
          resolve(responseData);
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(postData);
    req.end();
  });
}

/**
 * 딜레이 함수
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 테스트 실행
 */
async function runTests() {
  console.log(`${colors.blue}=== Google Sheets 매출 추적 테스트 ===${colors.reset}\n`);

  // 테스트 1: 일반 매출 (10만원 미만)
  console.log(`${colors.green}테스트 1: 일반 매출 (알림 없음)${colors.reset}`);
  try {
    const response = await makePostRequest(WEBHOOK_URL, {
      customer_name: "김철수",
      product: "기본 패키지",
      amount: 75000,
      status: "완료"
    });
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');
  await delay(2000);

  // 테스트 2: 대형 거래 (10만원 이상)
  console.log(`${colors.green}테스트 2: 대형 거래 (알림 발생)${colors.reset}`);
  try {
    const response = await makePostRequest(WEBHOOK_URL, {
      customer_name: "이영희",
      product: "프리미엄 패키지",
      amount: 250000,
      status: "완료"
    });
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');
  await delay(2000);

  // 테스트 3: 진행중 상태
  console.log(`${colors.green}테스트 3: 진행중 상태${colors.reset}`);
  try {
    const response = await makePostRequest(WEBHOOK_URL, {
      customer_name: "박민수",
      product: "스탠다드 패키지",
      amount: 120000,
      status: "진행중"
    });
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');
  await delay(2000);

  // 테스트 4: 대량 데이터 (여러 건)
  console.log(`${colors.blue}테스트 4: 대량 데이터 전송 (5건)${colors.reset}`);

  const customers = ["정수진", "강동원", "송혜교", "이병헌", "전지현"];
  const products = ["기본 패키지", "스탠다드 패키지", "프리미엄 패키지", "엔터프라이즈", "커스텀 패키지"];
  const amounts = [65000, 89000, 180000, 350000, 125000];

  for (let i = 0; i < 5; i++) {
    console.log(`${colors.green}  → 거래 ${i+1}/5 전송중...${colors.reset}`);
    try {
      await makePostRequest(WEBHOOK_URL, {
        customer_name: customers[i],
        product: products[i],
        amount: amounts[i],
        status: "완료"
      });
    } catch (error) {
      console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
    }
    await delay(1000);
  }

  console.log(`${colors.green}  ✓ 5건 전송 완료${colors.reset}\n`);

  // 테스트 5: 에러 케이스 - 필수 필드 누락
  console.log(`${colors.red}테스트 5: 에러 케이스 (금액 누락)${colors.reset}`);
  try {
    const response = await makePostRequest(WEBHOOK_URL, {
      customer_name: "조인성",
      product: "테스트 패키지",
      status: "완료"
    });
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.yellow}Expected error: ${error.message}${colors.reset}`);
  }
  console.log('');

  console.log(`${colors.blue}=== 테스트 완료 ===${colors.reset}`);
  console.log(`${colors.blue}Google Sheets를 확인하여 데이터가 정상적으로 입력되었는지 확인하세요.${colors.reset}`);
}

// 실행
runTests().catch(console.error);
