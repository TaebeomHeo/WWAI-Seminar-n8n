# Google Sheets 매출 추적 시스템 테스트 스크립트 (PowerShell)
# 사용법: .\test-sales-tracker.ps1 YOUR_WEBHOOK_URL

param(
    [string]$WebhookUrl = "https://your-n8n-instance.app.n8n.cloud/webhook/sales"
)

Write-Host "=== Google Sheets 매출 추적 테스트 ===" -ForegroundColor Blue
Write-Host ""

# 테스트 1: 일반 매출 (10만원 미만)
Write-Host "테스트 1: 일반 매출 (알림 없음)" -ForegroundColor Green
$body1 = @{
    customer_name = "김철수"
    product = "기본 패키지"
    amount = 75000
    status = "완료"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body1 -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""
Start-Sleep -Seconds 2

# 테스트 2: 대형 거래 (10만원 이상)
Write-Host "테스트 2: 대형 거래 (알림 발생)" -ForegroundColor Green
$body2 = @{
    customer_name = "이영희"
    product = "프리미엄 패키지"
    amount = 250000
    status = "완료"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body2 -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""
Start-Sleep -Seconds 2

# 테스트 3: 진행중 상태
Write-Host "테스트 3: 진행중 상태" -ForegroundColor Green
$body3 = @{
    customer_name = "박민수"
    product = "스탠다드 패키지"
    amount = 120000
    status = "진행중"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body3 -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""
Start-Sleep -Seconds 2

# 테스트 4: 대량 데이터 (여러 건)
Write-Host "테스트 4: 대량 데이터 전송 (5건)" -ForegroundColor Blue

$customers = @("정수진", "강동원", "송혜교", "이병헌", "전지현")
$products = @("기본 패키지", "스탠다드 패키지", "프리미엄 패키지", "엔터프라이즈", "커스텀 패키지")
$amounts = @(65000, 89000, 180000, 350000, 125000)

for ($i = 0; $i -lt 5; $i++) {
    Write-Host "  → 거래 $($i+1)/5 전송중..." -ForegroundColor Green

    $body = @{
        customer_name = $customers[$i]
        product = $products[$i]
        amount = $amounts[$i]
        status = "완료"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType "application/json" | Out-Null
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }

    Start-Sleep -Seconds 1
}

Write-Host "  ✓ 5건 전송 완료" -ForegroundColor Green
Write-Host ""

# 테스트 5: 에러 케이스 - 필수 필드 누락
Write-Host "테스트 5: 에러 케이스 (금액 누락)" -ForegroundColor Red
$body5 = @{
    customer_name = "조인성"
    product = "테스트 패키지"
    status = "완료"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body5 -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Expected error: $_" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== 테스트 완료 ===" -ForegroundColor Blue
Write-Host "Google Sheets를 확인하여 데이터가 정상적으로 입력되었는지 확인하세요." -ForegroundColor Blue
