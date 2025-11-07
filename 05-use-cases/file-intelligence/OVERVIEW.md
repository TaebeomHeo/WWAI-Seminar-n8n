# 프로젝트 5: 공유 폴더 파일 자동 분석 시스템 - 개요

## 📊 프로젝트 소개

팀 공유 폴더에 업로드되는 문서를 **AI가 자동으로 분석**하고, 기존 유사 문서와 **지능형 비교**를 수행하여 팀에게 **즉시 알려주는** 완전 자동화 시스템입니다.

### 💡 해결하는 문제

- ❌ 새로 올라온 문서를 일일이 확인해야 함
- ❌ 비슷한 파일명의 문서들이 산재해 있음
- ❌ 문서 버전 관리가 안 되어 혼란 발생
- ❌ 중요한 문서가 묻혀서 늦게 확인됨
- ❌ 문서 간 차이점을 일일이 비교해야 함

### ✅ 제공하는 솔루션

- ✅ 5분마다 자동 모니터링 (또는 실시간 Webhook)
- ✅ AI가 3-5문장으로 문서 자동 요약
- ✅ 유사한 파일 자동 감지 및 비교 분석
- ✅ 긴급도 자동 판단 및 우선순위 알림
- ✅ Slack/Email로 팀 전체에 즉시 공유

---

## 🎯 핵심 기능

### 1. **다양한 모니터링 방식**

| 방식 | 특징 | 적합한 경우 |
|------|------|------------|
| **Polling** | 5분 간격 체크, 안정적 | 대부분의 경우 (권장) |
| **Webhook** | 실시간 알림, API 효율적 | 즉각적인 대응 필요 시 |

### 2. **여러 플랫폼 지원**

```
✅ Google Drive       (완전 구현)
✅ Microsoft OneDrive (가이드 포함)
✅ Dropbox           (가이드 포함)
✅ NAS 서버          (Samba/FTP 연동 가능)
```

### 3. **가장 똑똑한 AI 모델 사용**

3대 최고 성능 AI 모델 모두 지원:

| 모델 | 장점 | 비용 | 추천 용도 |
|------|------|------|-----------|
| **GPT-4 Turbo** | 가장 정확한 분석 | 높음 | 중요 계약서, 제안서 |
| **Claude 3.5 Sonnet** | 긴 문서 처리 우수 | 중간 | 기술 문서, 보고서 |
| **Gemini 1.5 Pro** | 무료 티어 제공 | 낮음 | 일반 문서, 회의록 |

### 4. **지능형 파일 비교**

```javascript
// 3가지 알고리즘 조합
1. Levenshtein Distance (문자 단위 유사도)
2. Jaccard Similarity (단어 단위 유사도)
3. 버전 패턴 감지 (v1/v2, 초안/최종, 날짜 등)

// 결과
"보고서_2024_v1.pdf" vs "보고서_2024_v2.pdf"
→ 97.2% 유사도
→ 동일 문서의 다른 버전으로 판단
→ AI로 v1과 v2의 차이점 자동 분석
```

### 5. **다양한 알림 채널**

| 채널 | 형식 | 사용 시점 |
|------|------|-----------|
| **Email** | HTML 상세 리포트 | 공식적인 알림 |
| **Slack** | 인터랙티브 블록 | 즉각적인 팀 공유 |
| **Teams** | 카드 메시지 | MS 365 조직 |
| **멀티채널** | 긴급도 기반 자동 선택 | 중요도에 따라 분기 |

---

## 📁 프로젝트 구조

```
05-use-cases/file-intelligence/
│
├── 📄 OVERVIEW.md                       ← 이 문서
├── 📄 README.md                          ← 6,000+ 줄 완전 구현 가이드
│
├── 📂 scripts/                           ← 유틸리티 도구
│   ├── similarity-calculator.js         ← 파일명 유사도 계산기
│   └── test-file-upload.py              ← Google Drive 테스트 업로더
│
├── 📂 workflows/ (예정)                  ← n8n 워크플로우 JSON
│   ├── google-drive-polling.json
│   ├── google-drive-webhook.json
│   └── onedrive-monitoring.json
│
└── 📂 data/ (예정)                       ← 샘플 데이터
    ├── sample-documents/
    └── processed-files-template.csv
```

---

## 🚀 빠른 시작

### 1단계: 필수 준비물

```bash
✅ n8n 계정 (Cloud 또는 Self-hosted)
✅ Google Drive 계정
✅ Google Cloud Console 프로젝트
✅ OpenAI API 키 (또는 Claude/Gemini)
```

### 2단계: 5분 만에 기본 설정

1. **Google Drive API 활성화**
   ```
   Google Cloud Console → API 라이브러리 → "Google Drive API" 활성화
   ```

2. **서비스 계정 생성**
   ```
   사용자 인증 정보 만들기 → 서비스 계정 → JSON 키 다운로드
   ```

3. **공유 폴더 설정**
   ```
   Google Drive 폴더 생성 → 서비스 계정 이메일과 공유 (편집자 권한)
   ```

4. **n8n에 인증 정보 추가**
   ```
   n8n Credentials → Google Sheets API → JSON 키 입력
   ```

5. **OpenAI API 키 등록**
   ```
   n8n Credentials → OpenAI → API 키 입력
   ```

### 3단계: 워크플로우 Import

```bash
# README.md의 코드를 복사하여 n8n에 붙여넣기
또는
# workflows/ 폴더의 JSON 파일 Import
```

### 4단계: 테스트

```bash
# 1. 테스트 파일 생성
python scripts/test-file-upload.py --create-samples

# 2. Google Drive에 업로드
python scripts/test-file-upload.py \
  --credentials service-account.json \
  --folder-id YOUR_FOLDER_ID \
  --file ./test-files/프로젝트_제안서_v1.txt

# 3. n8n에서 워크플로우 실행 (Manual Trigger)

# 4. 5분 후 v2 파일 업로드
python scripts/test-file-upload.py \
  --credentials service-account.json \
  --folder-id YOUR_FOLDER_ID \
  --file ./test-files/프로젝트_제안서_v2.txt

# 5. 비교 분석 결과 확인!
```

---

## 🎓 학습 내용

이 프로젝트를 완성하면 다음을 배우게 됩니다:

### 1. API 연동 고급 기법
- ✅ Google Drive API 완전 활용
- ✅ Polling vs Webhook 비교 및 구현
- ✅ OAuth 2.0 인증
- ✅ 증분 동기화 (Incremental Sync)
- ✅ API 한도 관리 및 재시도 로직

### 2. 알고리즘 구현
- ✅ **Levenshtein Distance** (편집 거리)
- ✅ **Jaccard Similarity** (집합 유사도)
- ✅ 정규식 패턴 매칭
- ✅ 가중 평균 점수 계산

### 3. AI 프롬프트 엔지니어링
- ✅ JSON Mode 활용 (구조화된 출력)
- ✅ Function Calling (정확한 분류)
- ✅ Few-Shot Learning (예제 기반 학습)
- ✅ Chain of Thought (단계별 사고)
- ✅ 비용 최적화 전략

### 4. 실전 문제 해결
- ✅ 대용량 파일 처리 (청크 분할)
- ✅ 다양한 파일 형식 지원 (PDF/Word/Excel)
- ✅ 에러 핸들링 및 복구
- ✅ 보안 고려사항 (민감 정보 필터링)
- ✅ 성능 최적화

---

## 🧪 제공되는 도구

### 1. 파일명 유사도 계산기

```bash
node scripts/similarity-calculator.js \
  "보고서_2024_v1.pdf" \
  "보고서_2024_v2.pdf"
```

**출력:**
```
파일명 유사도 분석 결과:

파일 1: 보고서_2024_v1.pdf
파일 2: 보고서_2024_v2.pdf

=== 유사도 점수 ===
Levenshtein 유사도: 94.74%
Jaccard 유사도: 100%
패턴 제거 후 유사도: 100%

최종 점수: 97.89%

=== 패턴 감지 ===
파일 1 패턴: { version: 'v1' }
파일 2 패턴: { version: 'v2' }

=== 분석 결과 ===
✅ 동일 문서의 다른 버전일 가능성이 높습니다.
```

**기능:**
- Levenshtein Distance 계산
- Jaccard Similarity 계산
- 버전/날짜 패턴 자동 감지
- CLI 도구로 즉시 사용 가능
- Node.js 모듈로도 import 가능

### 2. Google Drive 테스트 업로더

```bash
# 샘플 파일 자동 생성
python scripts/test-file-upload.py --create-samples

# 생성되는 파일:
# - 프로젝트_제안서_v1.txt
# - 프로젝트_제안서_v2.txt (수정본)
# - 팀회의록_2024_11_06.txt
```

**업로드:**
```bash
python scripts/test-file-upload.py \
  --credentials service-account.json \
  --folder-id 1a2b3c4d5e6f \
  --file ./test-files/프로젝트_제안서_v1.txt
```

**출력:**
```
📤 파일 업로드 중: 프로젝트_제안서_v1.txt

✅ 업로드 완료!
파일 ID: 1XyZ...
파일명: 프로젝트_제안서_v1.txt
URL: https://drive.google.com/file/d/...
업로드 시간: 2024-11-07T10:30:00Z
```

---

## 💼 실전 활용 예시

### 예시 1: 프로젝트 문서 관리

**시나리오:**
```
팀원이 "프로젝트_제안서_최종.pdf"를 업로드
→ AI가 3분 안에 요약 생성
→ 기존 "프로젝트_제안서_초안.pdf"와 95% 유사도 감지
→ 두 문서 차이점 자동 분석:
   - 예산이 5천만원 → 5천5백만원으로 증액
   - 일정이 1주 연장됨
   - 기능 2개 추가됨
→ Slack으로 팀 전체 공유
```

**효과:**
- ⏱️ 문서 검토 시간 80% 단축
- 📊 변경사항 놓치지 않음
- 👥 팀 전체 즉시 공유

### 예시 2: 계약서 관리

**시나리오:**
```
법무팀이 "공급계약서_2024_수정본.docx" 업로드
→ AI가 계약서로 분류
→ 표준 계약서 템플릿과 비교
→ 비표준 조항 3개 발견:
   - 지급 조건 변경 (30일 → 60일)
   - 위약금 조항 추가
   - 계약 기간 1년 연장
→ 긴급 알림으로 Email + Slack 동시 발송
```

**효과:**
- ⚠️ 리스크 포인트 즉시 파악
- 📋 계약 검토 프로세스 자동화
- 🔒 표준 준수 여부 자동 체크

### 예시 3: 회의록 자동 처리

**시나리오:**
```
"월간팀회의록_2024_11.txt" 업로드
→ AI가 회의록으로 분류
→ 자동 요약:
   - 주요 결정사항 3개 추출
   - 액션 아이템 5개 추출
   - 담당자별로 분류
→ 각 담당자에게 개별 알림
→ 다음 회의 전 자동 리마인더
```

**효과:**
- 📝 회의록 정리 시간 제로
- ✅ 액션 아이템 누락 방지
- 🔔 자동 리마인더

### 예시 4: 기술 문서 버전 관리

**시나리오:**
```
"API_스펙_v2.3.md" 업로드
→ "API_스펙_v2.2.md"와 자동 비교
→ 변경사항 감지:
   - 새로운 엔드포인트 2개 추가
   - 기존 응답 형식 변경
   - deprecated 항목 3개
→ 개발팀 Slack 채널에 변경사항 요약 발송
→ 변경 이력을 자동으로 CHANGELOG에 추가
```

**효과:**
- 🔄 API 변경사항 추적 자동화
- 📚 문서 버전 히스토리 관리
- 👨‍💻 개발팀 즉시 업데이트 인지

---

## 📊 구현 옵션 비교

### 모니터링 방식

| 특징 | Polling | Webhook |
|------|---------|---------|
| **실시간성** | 5분 지연 | 즉시 |
| **안정성** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **설정 난이도** | 쉬움 | 중간 |
| **API 호출** | 많음 | 적음 |
| **추천** | 대부분의 경우 | 긴급 대응 필요 시 |

### AI 모델 선택

| 상황 | 추천 모델 | 이유 |
|------|-----------|------|
| 중요한 계약서, 제안서 | GPT-4 Turbo | 가장 정확한 분석 |
| 긴 기술 문서 (100페이지+) | Claude 3.5 | 200K 컨텍스트 |
| 일반 회의록, 보고서 | GPT-3.5 Turbo | 비용 효율적 |
| 예산이 제한적인 경우 | Gemini 1.5 Pro | 무료 티어 |
| 이미지 포함 문서 | Gemini 1.5 Pro | 멀티모달 지원 |

### 알림 채널 전략

```javascript
// 긴급도 기반 자동 선택
if (urgency === "긴급") {
  sendSlack();    // 즉시 알림
  sendEmail();    // 공식 기록
} else if (urgency === "높음") {
  sendSlack();    // 팀 공유
} else {
  // 일반: 매일 아침 요약 발송
  saveToDigest();
}
```

---

## 💰 비용 예상

### 시나리오: 중소기업 (팀원 20명)

**가정:**
- 하루 평균 20개 문서 업로드
- 문서당 평균 5,000 단어
- 월 22일 근무

**AI API 비용 (GPT-3.5 Turbo 사용 시):**
```
입력: 5,000 단어 × 1.3 = 6,500 토큰
출력: 500 토큰 (요약)

문서당 비용:
- 입력: 6.5K × $0.0015 = $0.01
- 출력: 0.5K × $0.002 = $0.001
- 합계: $0.011

월 비용:
- 20개/일 × 22일 × $0.011 = $4.84/월
```

**비교 분석 추가 시 (+30%):**
```
월 비용: $4.84 × 1.3 = $6.29/월
```

**총 비용:**
```
AI API: $6.29/월
n8n Cloud: $20/월 (Basic Plan)
Google Workspace: $0 (기존 사용 중)

합계: 약 $26/월 (₩35,000/월)
```

**절감 효과:**
```
문서 검토 시간: 20분 → 5분 (75% 감소)
시간 절감: 15분 × 20개 × 22일 = 110시간/월
인건비 환산 (시급 ₩30,000): ₩3,300,000/월

ROI: ₩3,300,000 / ₩35,000 = 94배
```

---

## 🔧 커스터마이징 가이드

### 1. 우리 조직에 맞게 조정하기

```javascript
// 긴급 키워드 추가
const urgentKeywords = [
  '긴급', '빨리', '즉시',  // 기본
  '임원', 'CEO', '이사회',  // 조직 특화
  '계약', '소송', '법적'    // 업종 특화
];

// 문서 타입 추가
const documentTypes = [
  '보고서', '제안서', '계약서',  // 기본
  '연구노트', '실험결과',        // 연구소
  '진료기록', '처방전'           // 병원
];
```

### 2. 알림 템플릿 수정

```html
<!-- 회사 브랜딩 추가 -->
<div class="header" style="background: #YOUR_BRAND_COLOR;">
  <img src="YOUR_LOGO_URL" height="40">
  <h2>📄 새 문서 업로드 알림</h2>
</div>
```

### 3. 자동화 규칙 추가

```javascript
// 자동 폴더 이동
if (documentType === '계약서') {
  moveToFolder('CONTRACTS_FOLDER_ID');
} else if (documentType === '회의록') {
  moveToFolder('MINUTES_FOLDER_ID');
}

// 자동 태그 추가
if (keywords.includes('예산')) {
  addLabel('budget');
}
```

---

## 🎯 다음 단계

### 단계 1: 기본 구현 (1-2일)
- [ ] Google Drive 모니터링 설정
- [ ] AI 요약 기능 구현
- [ ] Slack 알림 연동
- [ ] 기본 테스트

### 단계 2: 고급 기능 추가 (3-5일)
- [ ] 파일명 유사도 검사
- [ ] AI 비교 분석 구현
- [ ] 이메일 리포트 템플릿
- [ ] 로그 시스템 구축

### 단계 3: 최적화 및 확장 (ongoing)
- [ ] 비용 최적화
- [ ] 성능 튜닝
- [ ] 다른 플랫폼 추가 (OneDrive, Dropbox)
- [ ] 팀 피드백 반영

---

## 📚 참고 자료

### 필수 문서
1. **[README.md](./README.md)** - 완전 구현 가이드 (6,000+ 줄)
2. **[similarity-calculator.js](./scripts/similarity-calculator.js)** - 유사도 계산 도구
3. **[test-file-upload.py](./scripts/test-file-upload.py)** - 테스트 업로더

### 외부 리소스
- [Google Drive API 문서](https://developers.google.com/drive)
- [OpenAI API 문서](https://platform.openai.com/docs)
- [n8n 공식 문서](https://docs.n8n.io)

### 커뮤니티
- [n8n Community Forum](https://community.n8n.io)
- [GitHub Issues](https://github.com/TaebeomHeo/WWAI-Seminar-n8n/issues)

---

## ❓ FAQ

### Q1: 어떤 파일 형식을 지원하나요?
**A:** PDF, Word (.docx), Excel (.xlsx), PowerPoint (.pptx), 텍스트 파일을 지원합니다. 이미지는 OCR을 통해 텍스트 추출 가능합니다.

### Q2: 비용이 얼마나 들까요?
**A:** 중소기업 기준 월 약 $26 (₩35,000). 문서 업로드량에 비례하며, GPT-3.5 사용 시 문서당 약 $0.01입니다.

### Q3: 기존 문서도 분석할 수 있나요?
**A:** 네! Manual Trigger로 기존 문서를 일괄 처리하거나, 시간 범위를 지정하여 재분석할 수 있습니다.

### Q4: 민감한 문서는 어떻게 처리하나요?
**A:** 키워드 기반 필터링으로 '기밀', 'confidential' 등이 포함된 문서는 AI 처리를 건너뛰고 관리자에게만 알립니다.

### Q5: Webhook이 작동하지 않으면?
**A:** Google Drive Webhook은 복잡할 수 있습니다. Polling 방식(5분 간격)을 사용하면 더 안정적입니다.

### Q6: 다른 AI 모델로 쉽게 변경할 수 있나요?
**A:** 네! AI 노드만 교체하면 됩니다. GPT-4, Claude, Gemini 모두 가이드가 제공됩니다.

---

## 🎉 성공 사례 (가상)

### 사례 1: 스타트업 A사
**Before:**
- 문서 검토 시간: 하루 2시간
- 버전 관리: 수동, 혼란 多

**After:**
- 문서 검토 시간: 하루 30분
- 버전 자동 추적, 변경사항 즉시 파악
- **ROI: 90배**

### 사례 2: 로펌 B사
**Before:**
- 계약서 검토: 변호사 30분/건
- 표준 준수 체크: 수동

**After:**
- 1차 검토: AI 3분/건
- 비표준 조항 자동 감지
- **변호사 시간 70% 절감**

---

**시작하기:** [README.md 구현 가이드 보기](./README.md)

**문의:** GitHub Issues 또는 n8n Community

**라이선스:** MIT (자유롭게 사용 및 수정 가능)
