#!/bin/bash

# Google Sheets 매출 추적 시스템 테스트 스크립트
# 사용법: ./test-sales-tracker.sh YOUR_WEBHOOK_URL

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

WEBHOOK_URL="${1:-https://your-n8n-instance.app.n8n.cloud/webhook/sales}"

echo -e "${BLUE}=== Google Sheets 매출 추적 테스트 ===${NC}\n"

# 테스트 1: 일반 매출 (10만원 미만)
echo -e "${GREEN}테스트 1: 일반 매출 (알림 없음)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "김철수",
    "product": "기본 패키지",
    "amount": 75000,
    "status": "완료"
  }' | jq '.'
echo -e "\n"

sleep 2

# 테스트 2: 대형 거래 (10만원 이상)
echo -e "${GREEN}테스트 2: 대형 거래 (알림 발생)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "이영희",
    "product": "프리미엄 패키지",
    "amount": 250000,
    "status": "완료"
  }' | jq '.'
echo -e "\n"

sleep 2

# 테스트 3: 진행중 상태
echo -e "${GREEN}테스트 3: 진행중 상태${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "박민수",
    "product": "스탠다드 패키지",
    "amount": 120000,
    "status": "진행중"
  }' | jq '.'
echo -e "\n"

sleep 2

# 테스트 4: 대량 데이터 (여러 건)
echo -e "${BLUE}테스트 4: 대량 데이터 전송 (5건)${NC}"

customers=("정수진" "강동원" "송혜교" "이병헌" "전지현")
products=("기본 패키지" "스탠다드 패키지" "프리미엄 패키지" "엔터프라이즈" "커스텀 패키지")
amounts=(65000 89000 180000 350000 125000)

for i in {0..4}; do
  echo -e "${GREEN}  → 거래 $((i+1))/5 전송중...${NC}"
  curl -s -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"customer_name\": \"${customers[$i]}\",
      \"product\": \"${products[$i]}\",
      \"amount\": ${amounts[$i]},
      \"status\": \"완료\"
    }" > /dev/null
  sleep 1
done

echo -e "${GREEN}  ✓ 5건 전송 완료${NC}\n"

# 테스트 5: 에러 케이스 - 필수 필드 누락
echo -e "${RED}테스트 5: 에러 케이스 (금액 누락)${NC}"
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "조인성",
    "product": "테스트 패키지",
    "status": "완료"
  }' | jq '.'
echo -e "\n"

echo -e "${BLUE}=== 테스트 완료 ===${NC}"
echo -e "${BLUE}Google Sheets를 확인하여 데이터가 정상적으로 입력되었는지 확인하세요.${NC}"
