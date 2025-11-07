#!/usr/bin/env node

/**
 * n8n Hello World 워크플로우 테스트 스크립트 (Node.js)
 * 사용법: node test-hello-world.js YOUR_WEBHOOK_URL
 */

const https = require('https');
const http = require('http');

// 색상 코드
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  red: '\x1b[31m'
};

const WEBHOOK_URL = process.argv[2] || 'https://your-n8n-instance.app.n8n.cloud/webhook/hello';

/**
 * HTTP GET 요청 함수
 */
function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;

    protocol.get(url, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve(data);
        }
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * 테스트 실행
 */
async function runTests() {
  console.log(`${colors.blue}=== n8n Hello World 테스트 ===${colors.reset}\n`);

  // 테스트 1: 기본 요청
  console.log(`${colors.green}테스트 1: 기본 GET 요청${colors.reset}`);
  try {
    const response = await makeRequest(WEBHOOK_URL);
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');

  // 테스트 2: Query Parameter 포함
  console.log(`${colors.green}테스트 2: Query Parameter 포함${colors.reset}`);
  try {
    const response = await makeRequest(`${WEBHOOK_URL}?name=홍길동`);
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');

  // 테스트 3: 여러 Parameter
  console.log(`${colors.green}테스트 3: 여러 Query Parameters${colors.reset}`);
  try {
    const response = await makeRequest(`${WEBHOOK_URL}?name=홍길동&city=서울`);
    console.log(JSON.stringify(response, null, 2));
  } catch (error) {
    console.log(`${colors.red}Error: ${error.message}${colors.reset}`);
  }
  console.log('');

  console.log(`${colors.blue}=== 테스트 완료 ===${colors.reset}`);
}

// 실행
runTests().catch(console.error);
