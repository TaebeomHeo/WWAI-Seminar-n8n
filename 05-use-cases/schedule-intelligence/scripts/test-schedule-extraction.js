#!/usr/bin/env node

/**
 * 일정 추출 테스트 스크립트 (Node.js)
 *
 * 실행 방법: node test-schedule-extraction.js
 */

const fs = require('fs');
const path = require('path');

// 색상 코드
const colors = {
  blue: '\x1b[34m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  reset: '\x1b[0m'
};

console.log(`${colors.blue}========================================${colors.reset}`);
console.log(`${colors.blue}일정 추출 테스트 스크립트 (Node.js)${colors.reset}`);
console.log(`${colors.blue}========================================\n${colors.reset}`);

// n8n webhook URL (사용자가 수정해야 함)
const WEBHOOK_URL = 'https://your-n8n-instance.com/webhook/schedule-intelligence';

// 샘플 이메일 디렉토리
const SAMPLE_DIR = path.join(__dirname, '..', 'data', 'sample-emails');

// 이메일 파일 목록
const EMAIL_FILES = [
  'meeting-simple.txt',
  'meeting-vague.txt',
  'deadline.txt',
  'event.txt'
];

/**
 * Webhook 호출 함수
 */
async function sendToWebhook(payload) {
  // 실제 환경에서는 주석 해제
  // const response = await fetch(WEBHOOK_URL, {
  //   method: 'POST',
  //   headers: { 'Content-Type': 'application/json' },
  //   body: JSON.stringify(payload)
  // });
  // return await response.json();

  // 테스트 모드
  return { success: true, message: 'Test mode - webhook not called' };
}

/**
 * 이메일 처리 함수
 */
async function processEmail(emailFile) {
  const filePath = path.join(SAMPLE_DIR, emailFile);

  if (!fs.existsSync(filePath)) {
    console.log(`${colors.red}❌ 파일을 찾을 수 없습니다: ${filePath}${colors.reset}`);
    return;
  }

  console.log(`${colors.green}처리 중: ${emailFile}${colors.reset}`);

  // 이메일 내용 읽기
  const emailContent = fs.readFileSync(filePath, 'utf8');

  // JSON 페이로드 생성
  const payload = {
    email_content: emailContent,
    source_file: emailFile,
    received_at: new Date().toISOString()
  };

  // Webhook 호출
  const response = await sendToWebhook(payload);

  // 결과 출력
  console.log(`${colors.blue}📤 Webhook 페이로드:${colors.reset}`);
  console.log(JSON.stringify(payload, null, 2));

  console.log(`${colors.green}✅ 처리 완료\n${colors.reset}`);
  console.log('---');
}

/**
 * 메인 실행 함수
 */
async function main() {
  console.log(`${colors.yellow}📧 샘플 이메일 처리 시작...\n${colors.reset}`);

  for (const emailFile of EMAIL_FILES) {
    await processEmail(emailFile);
    // 다음 이메일 처리 전 대기
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log(`\n${colors.green}========================================${colors.reset}`);
  console.log(`${colors.green}모든 테스트 완료!${colors.reset}`);
  console.log(`${colors.green}========================================\n${colors.reset}`);

  console.log(`${colors.yellow}💡 실제 테스트를 위해:${colors.reset}`);
  console.log('1. WEBHOOK_URL을 실제 n8n webhook 주소로 변경하세요');
  console.log('2. sendToWebhook 함수의 fetch 호출 주석을 해제하세요 (line 41-46)');
  console.log('');
}

// 실행
main().catch(console.error);
