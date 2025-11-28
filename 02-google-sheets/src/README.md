# 02. Google Sheets 연동 (Code 구현)

이 디렉토리는 `02-google-sheets` 모듈의 n8n 워크플로우를 Python과 Node.js 코드로 직접 구현한 예제를 포함합니다.
n8n과 같은 워크플로우 자동화 툴이 내부적으로 어떻게 동작하는지 이해하고, 직접 코드로 자동화 로직을 구현해보고 싶은 분들을 위한 자료입니다.

## 📁 디렉토리 구조

```
src/
├── python/
│   ├── main.py               # FastAPI를 사용한 Python 구현체
│   └── requirements.txt      # Python 종속성 파일
├── nodejs/
│   ├── index.js              # Express.js를 사용한 Node.js 구현체
│   └── package.json          # Node.js 종속성 파일
├── credentials.json.example  # 인증 정보 파일 예시
└── README.md                 # 현재 파일
```

---

## 🔧 사전 준비: `credentials.json` 파일 생성

코드 실행을 위해 Google Cloud 서비스 계정 키와 대상 Google Sheets의 ID가 필요합니다.

**1단계: 인증 정보 파일 복사**
먼저 `credentials.json.example` 파일을 `credentials.json`으로 복사합니다.

```bash
cp credentials.json.example credentials.json
```

**2단계: Google Cloud 서비스 계정 키 준비**
- 아직 서비스 계정 키(`*.json` 파일)를 받지 않았다면, 메인 폴더의 **[Google Cloud 설정 가이드](../GOOGLE_CLOUD_SETUP.md)** 문서를 따라 키를 다운로드하세요.

**3단계: `credentials.json` 파일 수정**
- 복사한 `credentials.json` 파일을 열고, 다운로드한 서비스 계정 키 파일의 내용을 `google_service_account` 값으로 통째로 붙여넣습니다.
- `spreadsheet_id` 값을 자동화할 Google Sheets의 ID로 변경합니다.
  - Google Sheets URL이 `https://docs.google.com/spreadsheets/d/THIS_IS_THE_ID/edit` 라면 `THIS_IS_THE_ID` 부분이 ID입니다.

**완성된 `credentials.json` 예시:**
```json
{
  "google_service_account": {
    "type": "service_account",
    "project_id": "n8n-automation-12345",
    "private_key_id": "abcdef...",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    "client_email": "...",
    "client_id": "...",
    "auth_uri": "...",
    "token_uri": "...",
    "auth_provider_x509_cert_url": "...",
    "client_x509_cert_url": "..."
  },
  "spreadsheet_id": "1aBcDeFgHiJkLmNoPqRsTuVwXyZ"
}
```

**4단계: Google Sheets 공유**
- [사전 준비 가이드](../README.md#5단계-google-sheets-공유)를 참고하여, 여러분의 Google Sheet에 서비스 계정 이메일(`client_email`)을 '편집자'로 추가하는 것을 잊지 마세요.

---

## 🐍 Python (FastAPI) 버전 실행하기

`python` 디렉토리에서 아래 단계를 실행하세요.

**1. 가상환경 생성 및 활성화 (권장)**
```bash
python3 -m venv venv
source venv/bin/activate
```

**2. 종속성 설치**
```bash
pip install -r requirements.txt
```

**3. 서버 실행**
```bash
# uvicorn main:app --reload
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
서버가 `http://localhost:8000` 에서 실행됩니다.

**4. 테스트**
새 터미널을 열고 아래 `curl` 명령어를 실행하여 테스트 데이터를 전송합니다.
```bash
curl -X POST http://localhost:8000/sales \
  -H "Content-Type: application/json" \
  -d 
'{ 
    "customer_name": "파이썬 고객",
    "product": "FastAPI 특강",
    "amount": 150000
  }'
```
실행 후 Google Sheets에 데이터가 추가되고, 서버 로그에 "🎉 대형 거래 발생!" 메시지가 출력되는지 확인하세요.

---

## 🟩 Node.js (Express.js) 버전 실행하기

`nodejs` 디렉토리에서 아래 단계를 실행하세요.

**1. 종속성 설치**
```bash
npm install
```

**2. 서버 실행**
```bash
npm start
```
서버가 `http://localhost:3000` 에서 실행됩니다.

**3. 테스트**
새 터미널을 열고 아래 `curl` 명령어를 실행하여 테스트 데이터를 전송합니다.
```bash
curl -X POST http://localhost:3000/sales \
  -H "Content-Type: application/json" \
  -d 
'{ 
    "customer_name": "노드 고객",
    "product": "Express 특강",
    "amount": 120000
  }'
```
실행 후 Google Sheets에 데이터가 추가되고, 서버 로그에 "🎉 대형 거래 발생!" 메시지가 출력되는지 확인하세요.
