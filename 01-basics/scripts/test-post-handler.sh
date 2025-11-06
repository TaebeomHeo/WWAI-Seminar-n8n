#!/bin/bash

# n8n POST Handler 워크플로우 테스트 스크립트
# 사용법: ./test-post-handler.sh YOUR_WEBHOOK_URL

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WEBHOOK_URL="${1:-https://your-n8n-instance.app.n8n.cloud/webhook/submit}"

echo -e "${BLUE}=== n8n POST Handler 테스트 ===${NC}\n"

# 테스트 1: 성공 케이스 - 모든 필드 포함
echo -e "${GREEN}테스트 1: 성공 케이스 (모든 필드 포함)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "email": "hong@example.com",
    "phone": "010-1234-5678"
  }' | jq '.'
echo -e "\n"

# 테스트 2: 실패 케이스 - name 필드 누락
echo -e "${RED}테스트 2: 실패 케이스 (name 필드 누락)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "hong@example.com",
    "phone": "010-1234-5678"
  }' | jq '.'
echo -e "\n"

# 테스트 3: 성공 케이스 - 최소 필드만
echo -e "${GREEN}테스트 3: 성공 케이스 (최소 필드)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "김철수"
  }' | jq '.'
echo -e "\n"

# 테스트 4: 한글 이름 테스트
echo -e "${GREEN}테스트 4: 한글 데이터 테스트${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "이영희",
    "email": "lee@example.com",
    "message": "안녕하세요! n8n 테스트입니다."
  }' | jq '.'
echo -e "\n"

# 테스트 5: 빈 객체
echo -e "${RED}테스트 5: 빈 객체${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{}' | jq '.'
echo -e "\n"

echo -e "${BLUE}=== 테스트 완료 ===${NC}"
