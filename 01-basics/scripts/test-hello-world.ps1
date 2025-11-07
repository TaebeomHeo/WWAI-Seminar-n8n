# n8n Hello World 워크플로우 테스트 스크립트 (PowerShell)
# 사용법: .\test-hello-world.ps1 YOUR_WEBHOOK_URL

param(
    [string]$WebhookUrl = "https://your-n8n-instance.app.n8n.cloud/webhook/hello"
)

Write-Host "=== n8n Hello World 테스트 ===" -ForegroundColor Blue
Write-Host ""

# 테스트 1: 기본 요청
Write-Host "테스트 1: 기본 GET 요청" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Get
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""

# 테스트 2: Query Parameter 포함
Write-Host "테스트 2: Query Parameter 포함" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$WebhookUrl?name=홍길동" -Method Get
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""

# 테스트 3: 여러 Parameter
Write-Host "테스트 3: 여러 Query Parameters" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$WebhookUrl?name=홍길동&city=서울" -Method Get
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== 테스트 완료 ===" -ForegroundColor Blue
