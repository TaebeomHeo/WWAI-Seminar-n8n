# PowerShell 테스트 스크립트

Write-Host "========================================" -ForegroundColor Blue
Write-Host "일정 추출 테스트 스크립트 (PowerShell)" -ForegroundColor Blue
Write-Host "========================================`n" -ForegroundColor Blue

# n8n webhook URL (사용자가 수정해야 함)
$webhookUrl = "https://your-n8n-instance.com/webhook/schedule-intelligence"

# 샘플 이메일 디렉토리
$sampleDir = Join-Path $PSScriptRoot "..\data\sample-emails"

# 이메일 파일 목록
$emailFiles = @(
    "meeting-simple.txt",
    "meeting-vague.txt",
    "deadline.txt",
    "event.txt"
)

Write-Host "📧 샘플 이메일 처리 시작...`n" -ForegroundColor Yellow

foreach ($emailFile in $emailFiles) {
    $filePath = Join-Path $sampleDir $emailFile

    if (-not (Test-Path $filePath)) {
        Write-Host "❌ 파일을 찾을 수 없습니다: $filePath" -ForegroundColor Red
        continue
    }

    Write-Host "처리 중: $emailFile" -ForegroundColor Green

    # 이메일 내용 읽기
    $emailContent = Get-Content $filePath -Raw -Encoding UTF8

    # JSON 페이로드 생성
    $payload = @{
        email_content = $emailContent
        source_file = $emailFile
        received_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    } | ConvertTo-Json -Depth 10

    # Webhook 호출 (실제 환경에서는 주석 해제)
    # $response = Invoke-RestMethod -Uri $webhookUrl -Method Post `
    #     -ContentType "application/json" -Body $payload

    # 테스트 모드: 로컬에서 결과 시뮬레이션
    Write-Host "📤 Webhook 페이로드:" -ForegroundColor Blue
    $payload | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host

    Write-Host "✅ 처리 완료`n" -ForegroundColor Green
    Write-Host "---"

    # 다음 이메일 처리 전 대기
    Start-Sleep -Seconds 1
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "모든 테스트 완료!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "💡 실제 테스트를 위해:" -ForegroundColor Yellow
Write-Host "1. `$webhookUrl을 실제 n8n webhook 주소로 변경하세요"
Write-Host "2. Invoke-RestMethod 명령어 주석을 해제하세요 (line 38-39)"
Write-Host ""
