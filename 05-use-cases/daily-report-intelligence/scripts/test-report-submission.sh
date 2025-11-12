#!/bin/bash

# Daily Report Submission Test Script (Bash)
# 일일보고서 제출 테스트 스크립트

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 사용법
if [ -z "$1" ]; then
    echo -e "${RED}사용법: $0 <WEBHOOK_URL>${NC}"
    echo ""
    echo "예시:"
    echo "  $0 https://your-n8n.com/webhook/daily-report-submit"
    exit 1
fi

WEBHOOK_URL="$1"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  일일보고서 제출 테스트${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Webhook URL: $WEBHOOK_URL"
echo ""

# 테스트 1: 우수한 보고서
echo -e "${YELLOW}[테스트 1/3] 우수한 보고서 제출...${NC}"
RESPONSE1=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "pm_name": "김철수",
    "pm_email": "kim@company.com",
    "project": "모바일 앱 리뉴얼",
    "content": "오늘 API 개발을 완료했습니다 (진행률 85%).\n\n완료된 작업:\n- 사용자 인증 API 12개 엔드포인트 구현\n- 단위 테스트 작성 (커버리지 92%)\n\n이슈: 응답 속도가 목표(0.5초)보다 느립니다 (현재 1.2초). 백엔드 최적화가 필요하며, 코드 리뷰를 요청드립니다.\n\n내일 계획:\n1. 남은 2개 엔드포인트 완료\n2. 성능 최적화"
  }')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 성공${NC}"
    echo "응답: ${RESPONSE1:0:100}..."
else
    echo -e "${RED}✗ 실패${NC}"
fi
echo ""

# 2초 대기
sleep 2

# 테스트 2: 부족한 보고서
echo -e "${YELLOW}[테스트 2/3] 부족한 보고서 제출...${NC}"
RESPONSE2=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "pm_name": "이영희",
    "pm_email": "lee@company.com",
    "project": "웹사이트 개편",
    "content": "오늘도 열심히 작업했습니다. 개발이 잘 진행되고 있습니다. 내일도 계속 작업하겠습니다."
  }')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 성공${NC}"
    echo "응답: ${RESPONSE2:0:100}..."
else
    echo -e "${RED}✗ 실패${NC}"
fi
echo ""

# 2초 대기
sleep 2

# 테스트 3: 위험 상태 보고서
echo -e "${YELLOW}[테스트 3/3] 위험 상태 보고서 제출...${NC}"
RESPONSE3=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "pm_name": "박민수",
    "pm_email": "park@company.com",
    "project": "API 고도화",
    "content": "진행률: 65% (목표 대비 -10%)\n\n치명적 이슈: 외부 파트너사 API가 어제부터 응답 없음. 결제 기능이 완전히 중단된 상태. 고객 문의 급증 (50건 이상).\n\n파트너사 담당자 연락 안 됨. 대체 API 검토 중이나 통합에 3일 소요 예상.\n\n긴급 도움 필요: 경영진 차원의 공식 요청 필요. 매출 손실 일 500만원 예상."
  }')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 성공${NC}"
    echo "응답: ${RESPONSE3:0:100}..."
else
    echo -e "${RED}✗ 실패${NC}"
fi
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  테스트 완료${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "다음 단계:"
echo "1. 이메일함 확인 (AI 피드백)"
echo "2. Google Sheets 대시보드 확인"
echo "3. Slack 알림 확인"
echo ""
