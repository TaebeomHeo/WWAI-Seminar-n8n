# 01. n8n 기초 및 환경 설정

## 📚 학습 목표

- n8n의 기본 개념 이해
- 첫 번째 워크플로우 만들기
- Webhook과 기본 노드 사용법 익히기

---

## 🎯 실습 1: Hello World 워크플로우

### 목표
Webhook을 통해 요청을 받고 응답을 반환하는 가장 기본적인 워크플로우를 만듭니다.

### 단계별 가이드

#### 1단계: 새 워크플로우 생성
1. n8n에 로그인합니다
2. 좌측 상단 "+" 버튼을 클릭하여 새 워크플로우 생성
3. 워크플로우 이름을 "01-Hello-World"로 설정

#### 2단계: Webhook 노드 추가
1. 캔버스에서 "+" 버튼 클릭
2. "Webhook" 검색 후 선택
3. 다음과 같이 설정:
   - **HTTP Method**: `GET`
   - **Path**: `hello`
   - **Response Mode**: `Last Node`

#### 3단계: Set 노드 추가
1. Webhook 노드 우측 "+" 버튼 클릭
2. "Set" 노드 검색 후 선택
3. "Add Field" 버튼 클릭하여 다음 필드 추가:

```json
{
  "message": "Hello World from n8n!",
  "timestamp": "={{$now}}",
  "source": "n8n automation",
  "your_input": "={{$json.query}}"
}
```

**설정 방법:**
- Field Name: `message` / Value: `Hello World from n8n!`
- Field Name: `timestamp` / Value: `={{$now}}`
- Field Name: `source` / Value: `n8n automation`
- Field Name: `your_input` / Value: `={{$json.query}}`

#### 4단계: Respond to Webhook 노드 추가
1. Set 노드 우측 "+" 버튼 클릭
2. "Respond to Webhook" 검색 후 선택
3. 기본 설정 그대로 사용 (Body에서 자동으로 이전 노드의 데이터 전달)

#### 5단계: 워크플로우 실행 및 테스트
1. 우측 상단 "Active" 토글을 켭니다
2. Webhook 노드를 클릭하여 "Production URL" 복사
3. 터미널이나 브라우저에서 테스트:

```bash
# 터미널에서 테스트
curl "YOUR_WEBHOOK_URL?name=홍길동"

# 또는 브라우저에서
# YOUR_WEBHOOK_URL?name=홍길동
```

### 📝 실습 과제

**과제 1**: 현재 시간을 한국 시간대로 표시하도록 수정하기
- 힌트: `={{$now.toFormat('yyyy-MM-dd HH:mm:ss', 'Asia/Seoul')}}`

**과제 2**: Query Parameter로 받은 이름을 인사말에 포함하기
- URL: `?name=홍길동` 형태로 받기
- 응답: `"안녕하세요, 홍길동님!"`

**과제 3**: 더 많은 정보 추가하기
- 워크플로우 ID 추가: `={{$workflow.id}}`
- 실행 ID 추가: `={{$execution.id}}`

---

## 🎯 실습 2: POST 데이터 처리하기

### 목표
POST 요청으로 JSON 데이터를 받아서 처리하는 워크플로우를 만듭니다.

### 단계별 가이드

#### 1단계: 새 워크플로우 생성
- 이름: "01-POST-Handler"

#### 2단계: Webhook 노드 설정
```
HTTP Method: POST
Path: submit
Response Mode: Last Node
```

#### 3단계: 데이터 검증 노드 추가 (IF 노드)
1. "IF" 노드 추가
2. 조건 설정:
   - Condition Type: `String`
   - Value 1: `={{$json.body.name}}`
   - Operation: `is not empty`

#### 4단계: 성공 응답 (True 분기)
1. IF 노드의 True 출력에 Set 노드 연결
2. 응답 데이터 구성:

```json
{
  "success": true,
  "message": "데이터가 성공적으로 접수되었습니다",
  "received_data": "={{$json.body}}",
  "processed_at": "={{$now}}"
}
```

3. Respond to Webhook 노드 연결

#### 5단계: 실패 응답 (False 분기)
1. IF 노드의 False 출력에 Set 노드 연결
2. 에러 응답 데이터 구성:

```json
{
  "success": false,
  "error": "name 필드가 필요합니다",
  "status_code": 400
}
```

3. Respond to Webhook 노드 연결

#### 6단계: 테스트

```bash
# 성공 케이스
curl -X POST YOUR_WEBHOOK_URL \
  -H "Content-Type: application/json" \
  -d '{"name": "홍길동", "email": "hong@example.com"}'

# 실패 케이스
curl -X POST YOUR_WEBHOOK_URL \
  -H "Content-Type: application/json" \
  -d '{"email": "hong@example.com"}'
```

### 📝 실습 과제

**과제 1**: 이메일 형식 검증 추가하기
- 힌트: IF 노드에서 정규식 사용 `={{/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test($json.body.email)}}`

**과제 2**: 여러 필드 검증하기
- name, email, phone 필드 모두 확인
- 어떤 필드가 누락되었는지 알려주기

**과제 3**: 데이터 저장 시뮬레이션
- Code 노드를 추가하여 받은 데이터를 정리하고 로그 출력하기

---

## 📁 참고 자료

### workflows/ 폴더
- `01-hello-world.json` - 완성된 Hello World 워크플로우
- `02-post-handler.json` - 완성된 POST 데이터 처리 워크플로우

### scripts/ 폴더
- `test-hello-world.sh` - Hello World 테스트 스크립트
- `test-post-handler.sh` - POST 데이터 처리 테스트 스크립트

### 💡 팁

1. **n8n 표현식(Expressions)**
   - `={{$json}}` - 현재 노드의 JSON 데이터
   - `={{$json.field}}` - 특정 필드 접근
   - `={{$now}}` - 현재 시간
   - `={{$workflow.id}}` - 워크플로우 ID

2. **디버깅**
   - 각 노드를 클릭하면 우측에 데이터가 표시됩니다
   - "Execute Node" 버튼으로 개별 노드 테스트 가능
   - "Execute Workflow" 버튼으로 전체 워크플로우 테스트

3. **일반적인 실수**
   - Webhook의 Response Mode를 "Last Node"로 설정하지 않음
   - Respond to Webhook 노드를 추가하지 않음
   - Expression 문법 오류 (중괄호 2개 `={{}}` 사용 필수)

---

## ✅ 완료 체크리스트

- [ ] Hello World 워크플로우 생성 및 테스트 완료
- [ ] Query Parameter 처리 이해
- [ ] POST 데이터 처리 워크플로우 생성 완료
- [ ] IF 노드를 사용한 조건 분기 이해
- [ ] 기본 n8n 표현식 사용법 숙지
- [ ] 모든 실습 과제 완료

---

## 🔧 다양한 환경에서 테스트하기

### 테스트 스크립트 사용법

이 폴더에는 여러 환경을 지원하는 테스트 스크립트가 제공됩니다:

#### Bash (macOS/Linux)
```bash
chmod +x scripts/test-hello-world.sh
./scripts/test-hello-world.sh YOUR_WEBHOOK_URL
```

#### PowerShell (Windows)
```powershell
.\scripts\test-hello-world.ps1 YOUR_WEBHOOK_URL
```

#### Node.js (크로스 플랫폼)
```bash
node scripts/test-hello-world.js YOUR_WEBHOOK_URL
```

#### Python (크로스 플랫폼)
```bash
python scripts/test-hello-world.py YOUR_WEBHOOK_URL
```

### 어떤 스크립트를 사용해야 할까요?

- **Windows 사용자**: PowerShell (`.ps1`) 또는 Node.js/Python
- **macOS/Linux 사용자**: Bash (`.sh`) 또는 Node.js/Python
- **Node.js에 익숙한 개발자**: Node.js (`.js`)
- **Python에 익숙한 개발자**: Python (`.py`)

---

**다음 단계**: [02. Google Sheets 연동](../02-google-sheets/README.md)
