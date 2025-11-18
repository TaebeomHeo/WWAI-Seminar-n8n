#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}일정 추출 테스트 스크립트${NC}"
echo -e "${BLUE}========================================${NC}\n"

# n8n webhook URL (사용자가 수정해야 함)
WEBHOOK_URL="https://your-n8n-instance.com/webhook/schedule-intelligence"

# 샘플 이메일 디렉토리
SAMPLE_DIR="../data/sample-emails"

# 이메일 파일 목록
EMAIL_FILES=(
  "meeting-simple.txt"
  "meeting-vague.txt"
  "deadline.txt"
  "event.txt"
)

echo -e "${YELLOW}📧 샘플 이메일 처리 시작...${NC}\n"

for email_file in "${EMAIL_FILES[@]}"; do
  file_path="${SAMPLE_DIR}/${email_file}"

  if [ ! -f "$file_path" ]; then
    echo -e "${RED}❌ 파일을 찾을 수 없습니다: ${file_path}${NC}"
    continue
  fi

  echo -e "${GREEN}처리 중: ${email_file}${NC}"

  # 이메일 내용 읽기
  email_content=$(cat "$file_path")

  # JSON 페이로드 생성
  json_payload=$(jq -n \
    --arg content "$email_content" \
    --arg filename "$email_file" \
    '{
      email_content: $content,
      source_file: $filename,
      received_at: (now | todate)
    }')

  # Webhook 호출 (실제 환경에서는 주석 해제)
  # response=$(curl -s -X POST "$WEBHOOK_URL" \
  #   -H "Content-Type: application/json" \
  #   -d "$json_payload")

  # 테스트 모드: 로컬에서 결과 시뮬레이션
  echo -e "${BLUE}📤 Webhook 페이로드:${NC}"
  echo "$json_payload" | jq '.'

  echo -e "${GREEN}✅ 처리 완료${NC}\n"
  echo "---"

  # 다음 이메일 처리 전 대기
  sleep 1
done

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}모든 테스트 완료!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}💡 실제 테스트를 위해:${NC}"
echo "1. WEBHOOK_URL을 실제 n8n webhook 주소로 변경하세요"
echo "2. curl 명령어 주석을 해제하세요 (line 45-47)"
echo "3. jq가 설치되어 있어야 합니다: brew install jq (macOS)"
echo ""
