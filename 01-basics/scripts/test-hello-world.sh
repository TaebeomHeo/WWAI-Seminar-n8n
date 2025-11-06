#!/bin/bash

# n8n Hello World 워크플로우 테스트 스크립트
# 사용법: ./test-hello-world.sh YOUR_WEBHOOK_URL

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WEBHOOK_URL="${1:-https://your-n8n-instance.app.n8n.cloud/webhook/hello}"

echo -e "${BLUE}=== n8n Hello World 테스트 ===${NC}\n"

# 테스트 1: 기본 요청
echo -e "${GREEN}테스트 1: 기본 GET 요청${NC}"
curl -s "$WEBHOOK_URL" | jq '.'
echo -e "\n"

# 테스트 2: Query Parameter 포함
echo -e "${GREEN}테스트 2: Query Parameter 포함${NC}"
curl -s "$WEBHOOK_URL?name=홍길동" | jq '.'
echo -e "\n"

# 테스트 3: 여러 Parameter
echo -e "${GREEN}테스트 3: 여러 Query Parameters${NC}"
curl -s "$WEBHOOK_URL?name=홍길동&city=서울" | jq '.'
echo -e "\n"

echo -e "${BLUE}=== 테스트 완료 ===${NC}"
