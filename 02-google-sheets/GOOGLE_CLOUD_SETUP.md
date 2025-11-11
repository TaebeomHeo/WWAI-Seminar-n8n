# Google Cloud Console 설정 가이드

> **소요 시간**: 약 15-20분
> **난이도**: ⭐⭐☆☆☆ (초급)
> **사전 요구사항**: Google 계정

이 가이드는 Google Sheets API를 n8n에서 사용하기 위한 Google Cloud Console 설정 방법을 **단계별로 상세하게** 안내합니다.

---

## 📋 목차

1. [전체 프로세스 개요](#전체-프로세스-개요)
2. [1단계: Google Cloud Console 접속](#1단계-google-cloud-console-접속)
3. [2단계: 새 프로젝트 생성](#2단계-새-프로젝트-생성)
4. [3단계: Google Sheets API 활성화](#3단계-google-sheets-api-활성화)
5. [4단계: 서비스 계정 생성](#4단계-서비스-계정-생성)
6. [5단계: JSON 키 파일 다운로드](#5단계-json-키-파일-다운로드)
7. [6단계: n8n에 인증 정보 추가](#6단계-n8n에-인증-정보-추가)
8. [7단계: Google Sheets 공유 설정](#7단계-google-sheets-공유-설정)
9. [8단계: 연결 테스트](#8단계-연결-테스트)
10. [문제 해결 (Troubleshooting)](#문제-해결)

---

## 전체 프로세스 개요

```
┌─────────────────────────────────────────────────────────────┐
│  Google Cloud Console 설정 흐름도                            │
└─────────────────────────────────────────────────────────────┘

1. Google Cloud Console 접속
   ↓
2. 새 프로젝트 생성 (예: "n8n-automation")
   ↓
3. Google Sheets API 활성화
   ↓
4. 서비스 계정 생성
   ↓
5. JSON 키 파일 다운로드 (.json 파일)
   ↓
6. n8n에 인증 정보 추가 (Service Account Email + Private Key)
   ↓
7. Google Sheets를 서비스 계정과 공유
   ↓
8. 연결 테스트 ✓
```

**중요**: 각 단계를 순서대로 진행해야 합니다. 단계를 건너뛰면 오류가 발생합니다.

---

## 1단계: Google Cloud Console 접속

### 1-1. 웹 브라우저에서 접속

```
URL: https://console.cloud.google.com
```

1. 웹 브라우저(Chrome, Safari, Edge 등)를 엽니다
2. 주소창에 `https://console.cloud.google.com` 입력
3. Google 계정으로 로그인

### 1-2. 첫 접속 시 나타나는 화면

**처음 접속하는 경우**:
- "Google Cloud Platform 시작하기" 또는 "약관 동의" 화면이 나타날 수 있습니다
- 약관에 동의하고 "동의 및 계속" 클릭

**이미 사용 중인 경우**:
- 대시보드 화면이 바로 표시됩니다
- 좌측 상단에 "프로젝트 선택" 드롭다운이 보입니다

### 1-3. 화면 구성 이해하기

```
┌────────────────────────────────────────────────────────┐
│ ☰ Google Cloud                    🔍 검색  🔔 알림  👤 │  ← 상단 바
├────────────────────────────────────────────────────────┤
│ 📋 프로젝트 선택: [프로젝트명 ▼]                        │  ← 프로젝트 선택 영역
├────────┬───────────────────────────────────────────────┤
│        │                                               │
│  메뉴  │              메인 콘텐츠 영역                  │
│  영역  │                                               │
│        │                                               │
└────────┴───────────────────────────────────────────────┘
```

---

## 2단계: 새 프로젝트 생성

### 2-1. 프로젝트 선택 드롭다운 클릭

1. 화면 상단의 **"프로젝트 선택"** 또는 **현재 프로젝트명** 클릭
2. 팝업 창이 나타납니다

### 2-2. "새 프로젝트" 버튼 클릭

팝업 창 우측 상단에 있는 **"새 프로젝트"** 버튼 클릭

### 2-3. 프로젝트 정보 입력

다음 정보를 입력합니다:

| 항목 | 입력 값 | 설명 |
|------|---------|------|
| **프로젝트 이름** | `n8n-automation` | 원하는 이름 (한글 가능) |
| **조직** | (선택사항) | 개인 계정은 "조직 없음" |
| **위치** | (선택사항) | 기본값 사용 |

**프로젝트 이름 작성 팁**:
- 영문, 한글, 숫자, 하이픈(-), 공백 사용 가능
- 예시: `n8n-sheets-integration`, `n8n 워크플로우`, `업무자동화-프로젝트`
- 나중에 여러 프로젝트를 구분하기 쉬운 이름 추천

### 2-4. "만들기" 버튼 클릭

- 프로젝트 생성에 약 10-30초 소요
- 화면 우측 상단에 🔔 알림으로 생성 완료 메시지 표시
- 자동으로 새 프로젝트로 전환됨

### 2-5. 프로젝트 생성 확인

화면 상단의 프로젝트 이름이 방금 만든 프로젝트로 변경되었는지 확인:

```
예상 화면:
📋 n8n-automation ▼  ← 프로젝트명이 여기에 표시됨
```

---

## 3단계: Google Sheets API 활성화

### 3-1. "API 및 서비스" 메뉴 이동

**방법 1: 좌측 메뉴 사용**
1. 좌측 상단의 **☰ (햄버거 메뉴)** 클릭
2. 메뉴에서 **"API 및 서비스"** 찾기
3. **"라이브러리"** 클릭

**방법 2: 검색 사용**
1. 상단의 🔍 검색창에 `API 라이브러리` 입력
2. 검색 결과에서 **"API 라이브러리"** 클릭

### 3-2. Google Sheets API 검색

API 라이브러리 화면에서:

1. 검색창에 `Google Sheets API` 입력
2. 검색 결과에서 **"Google Sheets API"** 카드 클릭
   - 아이콘: 초록색 시트 모양
   - 설명: "Google Sheets API를 사용하여..."

### 3-3. API 활성화

1. **"사용"** 또는 **"Enable"** 버튼 클릭
2. 활성화 완료까지 약 5-10초 소요
3. 활성화 완료 후 화면이 API 세부정보 페이지로 전환됨

### 3-4. 활성화 확인

활성화가 성공하면 다음과 같이 표시됩니다:

```
✓ Google Sheets API
  [사용 설정됨]

  [ 사용자 인증 정보 관리 ]  [ 측정항목 ]  [ 할당량 ]
```

**확인 포인트**:
- "사용 설정됨" 또는 "Enabled" 상태 표시
- "사용 중지" 또는 "Disable" 버튼이 보임 (사용 안 함!)

---

## 4단계: 서비스 계정 생성

### 4-1. "사용자 인증 정보" 페이지 이동

**방법 1: API 세부정보 페이지에서**
- **"사용자 인증 정보 만들기"** 또는 **"Create Credentials"** 버튼 클릭

**방법 2: 좌측 메뉴에서**
1. 좌측 메뉴의 **"API 및 서비스"** 클릭
2. **"사용자 인증 정보"** 클릭

### 4-2. 인증 정보 유형 선택

1. **"+ 사용자 인증 정보 만들기"** 버튼 클릭 (상단)
2. 드롭다운 메뉴에서 **"서비스 계정"** 선택

**왜 서비스 계정인가?**
- OAuth 2.0: 사용자가 직접 로그인 필요 (대화형)
- API 키: 보안 수준 낮음, Sheets API에 권장 안 됨
- **서비스 계정**: 자동화에 최적, n8n에서 권장 ✓

### 4-3. 서비스 계정 세부정보 입력

**1단계: 서비스 계정 세부정보**

| 항목 | 입력 값 | 예시 |
|------|---------|------|
| **서비스 계정 이름** | `n8n-sheets-automation` | (필수) 알아보기 쉬운 이름 |
| **서비스 계정 ID** | (자동 생성) | `n8n-sheets-automation@...` |
| **서비스 계정 설명** | `n8n 워크플로우용` | (선택) 용도 설명 |

입력 후 **"만들기 및 계속하기"** 클릭

### 4-4. 역할 부여 (선택사항)

**2단계: 이 서비스 계정에 프로젝트 액세스 권한 부여**

- 이 단계는 **건너뛰어도 됩니다** (선택사항)
- Google Sheets는 파일 단위로 권한 부여 가능
- **"계속"** 버튼 클릭

### 4-5. 사용자 액세스 권한 (선택사항)

**3단계: 사용자에게 이 서비스 계정의 액세스 권한 부여**

- 이 단계도 **건너뛰어도 됩니다** (선택사항)
- **"완료"** 버튼 클릭

### 4-6. 서비스 계정 생성 확인

서비스 계정 목록에 새로 만든 계정이 표시됩니다:

```
이메일                                             이름
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
n8n-sheets-automation@프로젝트ID.iam...    n8n-sheets-automation
```

**중요**: 이메일 주소 전체를 메모장에 복사해두세요! (나중에 Google Sheets 공유 시 필요)

---

## 5단계: JSON 키 파일 다운로드

### 5-1. 서비스 계정 클릭

방금 만든 서비스 계정의 **이메일 주소** 클릭

### 5-2. "키" 탭 이동

1. 서비스 계정 세부정보 페이지에서 상단의 **"키"** 탭 클릭
2. 현재 키 목록 확인 (처음이면 비어있음)

### 5-3. 새 키 만들기

1. **"키 추가"** 버튼 클릭
2. 드롭다운에서 **"새 키 만들기"** 선택

### 5-4. 키 유형 선택

팝업 창에서:
- **JSON** 선택 (권장) ← 반드시 이것 선택!
- P12는 선택하지 마세요

**"만들기"** 버튼 클릭

### 5-5. JSON 파일 자동 다운로드

- 브라우저가 `.json` 파일을 자동으로 다운로드합니다
- 파일명 예시: `n8n-automation-a1b2c3d4e5f6.json`

**⚠️ 중요한 보안 경고**:
```
이 JSON 파일은 Google 계정에 접근할 수 있는 비밀 키입니다!

✓ 안전한 위치에 보관하세요
✓ 절대로 GitHub, 공개 저장소에 업로드하지 마세요
✓ 이메일로 전송하지 마세요
✓ 팀원과 공유할 때는 안전한 방법 사용 (1Password, Vault 등)
✗ 데스크톱, 다운로드 폴더에 그대로 두지 마세요
```

### 5-6. JSON 파일 내용 확인

다운로드한 JSON 파일을 텍스트 에디터로 열어보세요:

```json
{
  "type": "service_account",
  "project_id": "n8n-automation-123456",
  "private_key_id": "a1b2c3d4e5f6...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBg...\n-----END PRIVATE KEY-----\n",
  "client_email": "n8n-sheets-automation@n8n-automation-123456.iam.gserviceaccount.com",
  "client_id": "123456789012345678901",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/..."
}
```

**n8n에서 필요한 정보**:
1. `client_email` - 서비스 계정 이메일 주소
2. `private_key` - 개인 키 (-----BEGIN PRIVATE KEY----- 부분 전체)

### 5-7. JSON 파일 안전하게 보관

**추천 보관 위치**:

**macOS/Linux**:
```bash
# 프로젝트별 credentials 폴더 생성
mkdir -p ~/Documents/n8n-credentials
mv ~/Downloads/n8n-automation-*.json ~/Documents/n8n-credentials/

# 파일 권한 제한 (본인만 읽기)
chmod 600 ~/Documents/n8n-credentials/*.json
```

**Windows**:
```
C:\Users\사용자명\Documents\n8n-credentials\
```

**보안 팁**:
- 파일 이름을 명확하게: `n8n-sheets-prod.json`, `n8n-sheets-dev.json`
- 백업본 보관 (암호화된 USB, 클라우드 저장소)
- `.gitignore`에 반드시 추가 (Git 사용 시)

---

## 6단계: n8n에 인증 정보 추가

### 6-1. n8n 워크플로우 에디터 열기

1. n8n 인스턴스 접속 (예: `http://localhost:5678` 또는 클라우드 URL)
2. 새 워크플로우 생성 또는 기존 워크플로우 열기

### 6-2. Google Sheets 노드 추가

1. 화면 우측의 **"+"** 버튼 클릭 (노드 추가)
2. 검색창에 `Google Sheets` 입력
3. **"Google Sheets"** 노드 클릭하여 추가

### 6-3. Credential 선택 화면

Google Sheets 노드를 클릭하면 우측 패널에 설정이 나타납니다:

```
Google Sheets
─────────────────────────────────
Credential to connect with:
  [Select Credential... ▼]

  [ + Create New Credential ]
```

**"Create New Credential"** 버튼 클릭

### 6-4. 인증 방법 선택

팝업에서 인증 방법 선택:

- **Google Sheets API (Service Account)** ← 이것 선택!
- Google Sheets OAuth2 API (사용자 로그인 방식)

**Service Account** 선택 후 다음 화면으로 진행

### 6-5. 인증 정보 입력

#### 방법 1: JSON 파일 전체 붙여넣기 (쉬움)

```
Google Sheets Service Account
─────────────────────────────────────
Credential Data:
┌─────────────────────────────────┐
│ {                               │
│   "type": "service_account",    │
│   "project_id": "...",          │
│   ...전체 JSON 내용...            │
│ }                               │
└─────────────────────────────────┘
```

1. 다운로드한 JSON 파일을 텍스트 에디터로 열기
2. **전체 내용 복사** (Ctrl+A → Ctrl+C 또는 Cmd+A → Cmd+C)
3. n8n의 "Credential Data" 필드에 **붙여넣기**

#### 방법 2: 개별 필드 입력 (권장 - 더 안전)

JSON 파일에서 필요한 정보만 추출:

| n8n 필드 | JSON 파일의 키 | 예시 값 |
|----------|----------------|---------|
| **Service Account Email** | `client_email` | `n8n-sheets-automation@...` |
| **Private Key** | `private_key` | `-----BEGIN PRIVATE KEY-----\n...` |

**Private Key 입력 시 주의사항**:
- `\n` (줄바꿈 문자)도 **그대로** 포함해야 합니다
- 따옴표("")는 제거하고 내용만 복사
- `-----BEGIN PRIVATE KEY-----`부터 `-----END PRIVATE KEY-----`까지 전체 복사

**올바른 예시**:
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
(여러 줄의 키 내용)
...ABCDEFG123456==
-----END PRIVATE KEY-----
```

### 6-6. Credential 이름 지정

상단의 "Credential name" 필드:
```
Credential name: Google Sheets - 매출관리용
```

**이름 짓기 팁**:
- 용도를 명확히: `Google Sheets - Production`, `Google Sheets - 테스트용`
- 여러 계정 사용 시 구분: `Google Sheets - 개인`, `Google Sheets - 회사`

### 6-7. 저장 및 테스트

1. **"Save"** 버튼 클릭
2. 자동으로 연결 테스트 시도

**성공 시**:
```
✓ Credential saved successfully
```

**실패 시**:
```
✗ Error: Invalid credentials
```
→ [문제 해결](#문제-해결) 섹션 참고

---

## 7단계: Google Sheets 공유 설정

이 단계를 **반드시** 수행해야 n8n이 Google Sheets에 접근할 수 있습니다!

### 7-1. 서비스 계정 이메일 주소 확인

JSON 파일에서 `client_email` 값 복사:
```
n8n-sheets-automation@n8n-automation-123456.iam.gserviceaccount.com
```

또는 Google Cloud Console → 서비스 계정 목록에서 확인

### 7-2. Google Sheets 열기

1. 작업할 Google Sheets 파일 열기 (https://sheets.google.com)
2. 또는 새 시트 생성

### 7-3. 공유 버튼 클릭

우측 상단의 **"공유"** 버튼 클릭

### 7-4. 서비스 계정 이메일 추가

공유 팝업에서:

1. **"사용자 및 그룹 추가"** 입력란에 서비스 계정 이메일 **전체** 붙여넣기
   ```
   n8n-sheets-automation@n8n-automation-123456.iam.gserviceaccount.com
   ```

2. 권한 선택:
   - **편집자** ← n8n이 데이터를 쓸 수 있어야 하면 이것 선택
   - **뷰어** ← 읽기만 필요하면 이것 선택

3. **"알림 보내기" 체크 해제** (서비스 계정은 이메일 못 받음)

4. **"완료"** 버튼 클릭

### 7-5. 공유 확인

시트 상단에 공유된 사용자 목록 확인:

```
공유 대상:
👤 나 (소유자)
🤖 n8n-sheets-automation@... (편집자)
```

**중요**: 서비스 계정 이메일이 목록에 표시되어야 합니다!

### 7-6. 여러 시트에 적용

같은 서비스 계정으로 여러 Google Sheets를 사용할 수 있습니다:
- 각 시트마다 **7-3 ~ 7-5 과정 반복**
- 같은 서비스 계정 이메일 주소로 공유

---

## 8단계: 연결 테스트

### 8-1. 테스트용 Google Sheets 준비

간단한 테스트 시트 생성:

| A    | B      | C     |
|------|--------|-------|
| 이름 | 이메일 | 나이  |
| 홍길동 | hong@example.com | 30 |
| 김철수 | kim@example.com | 25 |

1. 시트 이름: `테스트` (또는 `Sheet1`)
2. 서비스 계정과 공유 완료

### 8-2. n8n 워크플로우 생성

**노드 구성**:
```
[Manual Trigger] → [Google Sheets]
```

1. **Manual Trigger** 노드 추가
2. **Google Sheets** 노드 추가

### 8-3. Google Sheets 노드 설정

| 설정 항목 | 값 |
|-----------|-----|
| **Credential** | 앞서 만든 인증 정보 선택 |
| **Operation** | `Read` |
| **Document** | Google Sheets URL 붙여넣기 |
| **Sheet** | `테스트` |
| **Range** | `A1:C10` (또는 비워두기) |

**Document 값**:
- 전체 URL: `https://docs.google.com/spreadsheets/d/1ABC...XYZ/edit#gid=0`
- 또는 ID만: `1ABC...XYZ`

### 8-4. 실행 및 결과 확인

1. **"Execute Workflow"** 버튼 클릭 (우측 상단)
2. 결과 확인

**성공 시**:
```json
[
  {
    "이름": "홍길동",
    "이메일": "hong@example.com",
    "나이": "30"
  },
  {
    "이름": "김철수",
    "이메일": "kim@example.com",
    "나이": "25"
  }
]
```

**실패 시**:
- 오류 메시지 확인
- [문제 해결](#문제-해결) 섹션 참고

### 8-5. 쓰기 테스트 (선택)

**노드 변경**:
```
[Manual Trigger] → [Google Sheets]
```

**Google Sheets 노드 설정**:
| 설정 항목 | 값 |
|-----------|-----|
| **Operation** | `Append` |
| **Document** | 같은 시트 |
| **Sheet** | `테스트` |

**데이터 입력** (Manual Trigger에서):
```json
{
  "이름": "이영희",
  "이메일": "lee@example.com",
  "나이": "28"
}
```

실행 후 Google Sheets에서 새 행이 추가되었는지 확인!

---

## 문제 해결

### 문제 1: "Invalid credentials" 오류

**증상**:
```
Error: Invalid JWT Signature
또는
Error: Invalid credentials
```

**원인**:
- Private Key가 잘못 복사됨
- `\n` (줄바꿈 문자)가 실제 줄바꿈으로 변환됨

**해결 방법**:

1. JSON 파일을 다시 열어서 `private_key` 값 확인
2. 따옴표 제외하고 **전체 내용** 복사 (-----BEGIN부터 -----END까지)
3. n8n에 다시 붙여넣기
4. `\n` 문자가 그대로 있는지 확인 (실제 줄바꿈이 아님!)

**올바른 형식**:
```
-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgk...\n...\n-----END PRIVATE KEY-----\n
```

---

### 문제 2: "Insufficient permissions" 오류

**증상**:
```
Error: The caller does not have permission
또는
Error: Insufficient permissions
```

**원인**:
- Google Sheets가 서비스 계정과 공유되지 않음
- 권한이 "뷰어"인데 쓰기 작업 시도

**해결 방법**:

1. Google Sheets 열기
2. 우측 상단 "공유" 버튼 클릭
3. 공유 목록에서 서비스 계정 이메일 확인
4. 없으면 [7단계](#7단계-google-sheets-공유-설정) 다시 수행
5. 있으면 권한을 "편집자"로 변경

---

### 문제 3: "Document not found" 오류

**증상**:
```
Error: Requested entity was not found
또는
Error: Document not found
```

**원인**:
- Google Sheets URL 또는 ID가 잘못됨
- 시트가 삭제되었거나 접근 권한 없음

**해결 방법**:

1. Google Sheets URL 다시 확인
   - 올바른 예: `https://docs.google.com/spreadsheets/d/1ABC...XYZ/edit`
   - ID만 사용: `1ABC...XYZ` (d/ 와 /edit 사이 부분)

2. 시트가 존재하는지 확인
3. 서비스 계정과 공유되었는지 확인

---

### 문제 4: "Range not found" 오류

**증상**:
```
Error: Unable to parse range
또는
Error: Range 'XXX'!A1:Z not found
```

**원인**:
- 시트 이름이 잘못됨
- 시트 이름에 특수문자나 공백 있음

**해결 방법**:

1. Google Sheets에서 시트 이름 정확히 확인
   - 하단 탭에 표시된 이름 그대로 사용

2. 시트 이름에 공백/특수문자 있으면 **작은따옴표**로 감싸기:
   ```
   올바름: '매출 관리'!A1:E10
   올바름: '2024년 데이터'!A:Z
   잘못됨: 매출 관리!A1:E10
   ```

3. n8n에서는 Sheet Name 필드에 따옴표 없이 입력:
   ```
   Sheet: 매출 관리   (따옴표 없음)
   ```

---

### 문제 5: Google Cloud 프로젝트 결제 활성화 요구

**증상**:
```
This API is only available for paid projects
또는
결제 계정을 활성화하세요
```

**원인**:
- Google Cloud는 무료 사용량 제공하지만, 일부 API는 결제 계정 연결 필요
- Google Sheets API는 대부분 **무료 사용량 내에서 충분**

**해결 방법**:

1. Google Cloud Console → "결제" 메뉴
2. "결제 계정 연결" (신용카드 등록)
3. **무료 할당량**:
   - 읽기: 하루 최대 500회
   - 쓰기: 하루 최대 100회
   - 대부분의 개인/소규모 프로젝트는 무료 범위 내

**비용 걱정하지 마세요**:
- 무료 할당량 초과 시에만 과금
- 초과 전 알림 설정 가능
- n8n 개인 사용은 거의 무료 범위 내

---

### 문제 6: JSON 파일을 다시 다운로드해야 하는 경우

**상황**:
- JSON 파일을 분실했거나 삭제됨
- Private Key가 노출되어 재발급 필요

**해결 방법**:

**옵션 1: 새 키 발급 (기존 서비스 계정 유지)**
1. Google Cloud Console → 서비스 계정 목록
2. 기존 서비스 계정 클릭
3. "키" 탭 → "키 추가" → "새 키 만들기"
4. JSON 선택 → 다운로드
5. n8n 인증 정보 업데이트

**옵션 2: 새 서비스 계정 생성**
1. [4단계](#4단계-서비스-계정-생성)부터 다시 수행
2. 새 서비스 계정 이메일로 Google Sheets 다시 공유

**보안 팁**:
- 기존 키가 노출되었다면 **반드시 삭제**
  - Google Cloud Console → 서비스 계정 → 키 탭 → 키 삭제
- 정기적으로 키 교체 (3개월~1년 주기)

---

### 문제 7: n8n에서 Credential 테스트 실패

**증상**:
- "Test" 버튼 클릭 시 오류
- 하지만 실제 워크플로우 실행은 성공

**원인**:
- n8n의 Credential 테스트는 Google Sheets 특정 파일 접근 시도
- 아직 어떤 시트도 공유하지 않았을 수 있음

**해결 방법**:
- 이 오류는 **무시해도 됩니다**
- 실제 워크플로우에서 공유된 시트에 접근하면 정상 작동
- 또는 테스트용 시트를 하나 만들어서 공유

---

### 문제 8: 한글 시트명 인식 안 됨

**증상**:
- 시트명이 한글인 경우 "Range not found" 오류

**해결 방법**:

**방법 1: 시트명을 영문으로 변경**
- `매출관리` → `Sales`
- `고객데이터` → `Customers`

**방법 2: URL 인코딩 사용** (고급)
- n8n Expression에서:
  ```javascript
  ={{encodeURIComponent('매출관리')}}
  ```

**방법 3: Sheet ID 사용**
- Google Sheets URL에서 `gid=` 부분 확인
  ```
  https://docs.google.com/spreadsheets/d/.../edit#gid=123456
                                                        ^^^^^^ 이 숫자
  ```
- n8n에서 시트 이름 대신 `gid:123456` 사용

---

## 📋 전체 체크리스트

설정이 완료되었는지 확인하세요:

- [ ] Google Cloud Console 프로젝트 생성 완료
- [ ] Google Sheets API 활성화됨 ("사용 설정됨" 상태)
- [ ] 서비스 계정 생성 완료
- [ ] JSON 키 파일 다운로드 완료
- [ ] JSON 키 파일 안전한 위치에 보관 (`.gitignore` 추가)
- [ ] 서비스 계정 이메일 주소 복사해둠
- [ ] n8n에 Google Sheets 인증 정보 추가 완료
- [ ] 인증 정보 테스트 성공 (또는 워크플로우 실행 성공)
- [ ] 작업할 Google Sheets를 서비스 계정과 공유 완료
- [ ] 공유 권한이 "편집자"로 설정됨 (쓰기 필요 시)
- [ ] 테스트 워크플로우 실행 성공 (읽기 또는 쓰기)

---

## 🎓 다음 단계

Google Cloud 설정이 완료되었습니다! 이제 다음을 진행하세요:

1. **[메인 실습 가이드로 돌아가기](README.md#실습-1-매출-데이터-자동-기록-시스템)**
   - 매출 데이터 자동 기록 시스템 구현
   - 고객 등급 자동 계산
   - 양방향 동기화 시스템

2. **고급 가이드 (선택)**
   - [Gmail API 연동](advanced/README.md#1-gmail-api-데이터-수집)
   - [Google Analytics 연동](advanced/README.md#2-google-analytics-4-데이터-수집)

---

## 🔗 유용한 링크

- [Google Cloud Console](https://console.cloud.google.com)
- [Google Sheets API 문서](https://developers.google.com/sheets/api)
- [n8n Google Sheets 노드 문서](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/)
- [서비스 계정 개념 설명](https://cloud.google.com/iam/docs/service-accounts)

---

## 💬 도움이 더 필요하신가요?

이 가이드를 따라했는데도 문제가 해결되지 않는다면:

1. 오류 메시지 전체를 복사해두세요
2. 어느 단계에서 막혔는지 확인하세요
3. [문제 해결](#문제-해결) 섹션을 다시 확인하세요
4. n8n 커뮤니티 포럼에 질문: https://community.n8n.io

---

**이전**: [README.md - 사전 준비](README.md#사전-준비)
**다음**: [README.md - 실습 1](README.md#실습-1-매출-데이터-자동-기록-시스템)
