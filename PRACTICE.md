# n8n 워크플로우 자동화 실습 가이드

이 저장소는 n8n을 활용한 업무 자동화를 학습하기 위한 실습 자료입니다.

## 📁 저장소 구조

```
WWAI-Seminar-n8n/
├── README.md                    # 전체 세미나 가이드 (이론)
├── PRACTICE.md                  # 실습 가이드 (이 파일)
├── CLAUDE.md                    # AI 어시스턴트를 위한 가이드
│
├── 01-basics/                   # Part 1: n8n 기초
│   ├── README.md               # 상세 실습 가이드
│   ├── scripts/                # 테스트 스크립트
│   ├── solutions/              # 완성된 워크플로우 JSON
│   ├── data/                   # 샘플 데이터
│   └── workflows/              # 여러분이 만들 워크플로우
│
├── 02-google-sheets/           # Part 2: Google Sheets 연동
│   ├── README.md
│   ├── scripts/
│   ├── solutions/
│   └── data/
│
├── 03-web-scraping/            # Part 3: 웹 스크래핑
│   ├── README.md
│   ├── scripts/
│   ├── solutions/
│   └── data/
│
├── 04-ai-automation/           # Part 4: AI 자동화
│   ├── README.md
│   ├── scripts/
│   ├── solutions/
│   └── data/
│
└── 05-use-cases/               # Part 5: 실무 프로젝트
    ├── README.md
    ├── solutions/
    └── data/
```

## 🚀 시작하기

### 1. 저장소 다운로드

```bash
# Git으로 클론
git clone https://github.com/your-repo/WWAI-Seminar-n8n.git
cd WWAI-Seminar-n8n

# 또는 ZIP 파일 다운로드
# https://github.com/your-repo/WWAI-Seminar-n8n/archive/main.zip
```

### 2. n8n 계정 준비

**옵션 A: n8n Cloud (권장 - 초보자)**
1. https://app.n8n.cloud 접속
2. 무료 계정 생성
3. 즉시 사용 가능

**옵션 B: 로컬 설치 (고급 사용자)**
```bash
# npx 사용 (Node.js 필요)
npx n8n

# Docker 사용
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

### 3. 필수 계정 준비 (실습 전에 미리 준비)

- [ ] **Google 계정**: Google Sheets, Gmail 연동용
- [ ] **OpenAI 계정**: AI 기능 사용 (크레딧 $5-10 권장)
- [ ] **Slack 계정** (선택): 알림 테스트용

## 📖 학습 순서

### Part 1: n8n 기초 (예상 시간: 30-40분)

**학습 목표:**
- n8n 인터페이스 익히기
- 첫 번째 워크플로우 만들기
- Webhook과 기본 노드 이해

**실습 단계:**
1. `01-basics/README.md` 열기
2. 단계별 가이드 따라하기
3. 두 가지 워크플로우 완성:
   - Hello World
   - POST 데이터 처리
4. 테스트 스크립트로 검증

**완료 체크:**
- [ ] Webhook URL에서 응답 받기 성공
- [ ] Query Parameter 처리 이해
- [ ] POST 데이터 검증 로직 구현
- [ ] 모든 실습 과제 완료

**막힐 때:**
- `solutions/` 폴더의 완성 예제 참고
- n8n 커뮤니티 포럼 검색: https://community.n8n.io

---

### Part 2: Google Sheets 연동 (예상 시간: 40-50분)

**학습 목표:**
- Google API 인증 설정
- Sheets 데이터 읽기/쓰기/업데이트
- 실시간 데이터 동기화

**사전 준비:**
1. Google Cloud Console에서 서비스 계정 생성
2. Google Sheets API 활성화
3. JSON 키 파일 다운로드
4. n8n에 인증 정보 등록

**실습 단계:**
1. `02-google-sheets/README.md` 참고
2. 사전 준비 단계 완료 (중요!)
3. 세 가지 워크플로우 구현:
   - 매출 데이터 자동 기록
   - 고객 등급 자동 계산
   - 양방향 동기화 시스템

**완료 체크:**
- [ ] Google Sheets API 연동 성공
- [ ] 데이터 자동 추가 작동
- [ ] 조건부 알림 기능 작동
- [ ] Sheets 데이터 읽기 및 처리 성공

**자주 발생하는 문제:**
- "Permission denied": 서비스 계정에 시트 편집 권한 부여 확인
- "Sheet not found": 시트 이름이 정확한지 확인
- 인증 실패: JSON 키 파일의 Service Account Email과 Private Key 확인

---

### Part 3: 웹 스크래핑 (예상 시간: 40-50분)

**학습 목표:**
- HTTP Request로 웹 데이터 수집
- HTML 파싱 및 데이터 추출
- 가격 모니터링 시스템 구축

**윤리적 고려사항:**
⚠️ 실습 전에 반드시 읽어주세요:
- `03-web-scraping/README.md`의 "웹 스크래핑 윤리 및 법적 고려사항" 섹션
- 실제 웹사이트 스크래핑 시 robots.txt 확인 필수
- 과도한 요청으로 서버에 부하를 주지 않기

**실습 단계:**
1. `data/sample-html.html` 파일로 연습
2. 기본 스크래핑 워크플로우 구현
3. 경쟁사 가격 모니터링 시스템 구축
4. CSS 선택자 치트시트 참고

**완료 체크:**
- [ ] HTML에서 데이터 추출 성공
- [ ] CSS 선택자 사용법 이해
- [ ] 가격 변동 감지 로직 작동
- [ ] 에러 처리 및 재시도 구현

**유용한 도구:**
- Chrome DevTools (F12): HTML 구조 확인
- CSS Selector Tester: https://try.jsoup.org/
- `data/css-selectors.md`: CSS 선택자 참고

---

### Part 4: AI 자동화 (예상 시간: 50-60분)

**학습 목표:**
- OpenAI API 연동
- AI 기반 감정 분석 및 분류
- 자동 콘텐츠 생성
- AI 챗봇 구현

**사전 준비:**
1. OpenAI 계정 생성: https://platform.openai.com
2. API 키 발급
3. 결제 정보 등록 (최소 $5 크레딧 권장)
4. n8n에 OpenAI 인증 정보 추가

**비용 참고:**
- GPT-3.5-turbo: 입력 $0.0015/1K 토큰, 출력 $0.002/1K 토큰
- 이 실습 전체 완료 시 예상 비용: $1-2 정도

**실습 단계:**
1. `04-ai-automation/README.md` 참고
2. 샘플 이메일 데이터로 감정 분석
3. AI 콘텐츠 생성 및 번역
4. 간단한 AI 챗봇 구현

**완료 체크:**
- [ ] OpenAI API 연동 성공
- [ ] 감정 분석 및 카테고리 분류 작동
- [ ] 우선순위 자동 계산 로직 구현
- [ ] AI 자동 응답 생성 성공

**프롬프트 엔지니어링 팁:**
- 명확한 역할 정의
- 구체적인 출력 형식 지정 (JSON 권장)
- Few-Shot 예제 제공
- 제약사항 명시

---

### Part 5: 실무 프로젝트 (예상 시간: 60-90분)

**학습 목표:**
- 실전 비즈니스 시나리오 해결
- 복잡한 워크플로우 설계
- 여러 기능 통합

**프로젝트 목록:**
1. **비즈니스 대시보드**: 여러 데이터 소스 통합 리포트
2. **고객 지원 시스템**: AI 기반 티켓 분류 및 자동 응답
3. **마케팅 자동화**: 리드 스코어링 및 개인화 캠페인
4. **소셜 미디어 자동화**: 콘텐츠 생성 및 스케줄링

**진행 방법:**
1. `05-use-cases/README.md`에서 프로젝트 선택
2. 요구사항 분석
3. 아키텍처 설계
4. 단계별 구현
5. 테스트 및 개선

**완료 체크:**
- [ ] 최소 1개 프로젝트 완성
- [ ] 에러 처리 추가
- [ ] 문서화 완료
- [ ] 실제 업무에 적용 가능한 수준

---

## 🎯 학습 로드맵

### 1일차 (3시간)
```
09:00-09:30  환경 설정 및 계정 준비
09:30-10:00  Part 1: n8n 기초
10:00-10:40  Part 2: Google Sheets 연동
10:40-10:50  휴식
10:50-11:30  Part 3: 웹 스크래핑
11:30-12:30  Part 4: AI 자동화
```

### 2일차 (심화 - 선택)
```
Part 5: 실무 프로젝트 완성
자신의 업무에 적용할 워크플로우 설계 및 구현
```

## 💡 학습 팁

### 효과적인 학습 방법

1. **손으로 직접 타이핑하기**
   - 복사-붙여넣기보다 직접 타이핑하며 이해하기
   - 코드를 읽고 이해한 후 작성하기

2. **작은 단계로 쪼개기**
   - 한 번에 전체 워크플로우를 만들지 말기
   - 노드 하나씩 추가하며 테스트하기
   - "Execute Node" 버튼으로 개별 노드 테스트

3. **에러는 배움의 기회**
   - 에러 메시지를 자세히 읽기
   - 어떤 노드에서 실패했는지 확인
   - 이전 노드의 출력 데이터 확인

4. **문서화 습관**
   - 각 워크플로우에 설명 추가
   - Sticky Note 노드 활용
   - 복잡한 로직은 주석 달기

5. **커뮤니티 활용**
   - n8n 커뮤니티 포럼 검색
   - Discord 채널 참여
   - 다른 사람의 워크플로우 참고

### 디버깅 체크리스트

워크플로우가 작동하지 않을 때:

1. [ ] 각 노드를 개별적으로 실행해보기
2. [ ] 이전 노드의 출력 데이터 확인
3. [ ] Expression 문법이 올바른지 확인 (`={{}}`)
4. [ ] 인증 정보가 올바르게 설정되었는지 확인
5. [ ] API 한도를 초과하지 않았는지 확인
6. [ ] n8n 버전이 최신인지 확인

### 데이터 구조 이해하기

n8n에서 가장 중요한 개념:

```javascript
// 현재 노드의 데이터
$json

// 특정 필드 접근
$json.field_name
$json["field name with spaces"]

// 이전 노드의 데이터
$node["Node Name"].json

// 모든 입력 데이터
$input.all()

// 첫 번째 입력
$input.first()

// 현재 시간
$now

// 워크플로우 정보
$workflow.id
$workflow.name
```

## 📚 추가 학습 자료

### 공식 리소스
- **n8n 공식 문서**: https://docs.n8n.io
- **n8n YouTube**: https://youtube.com/@n8n-io
- **워크플로우 템플릿**: https://n8n.io/workflows

### 커뮤니티
- **포럼**: https://community.n8n.io
- **Discord**: https://discord.gg/n8n
- **GitHub**: https://github.com/n8n-io/n8n

### 학습 자료
- **Expression 치트시트**: https://docs.n8n.io/code-examples/expressions/
- **노드 레퍼런스**: https://docs.n8n.io/integrations/
- **블로그**: https://n8n.io/blog

## 🎓 수료 후 다음 단계

### 실무 적용

1. **현재 업무 분석**
   - 반복적인 작업 리스트 작성
   - 자동화 가능한 프로세스 식별
   - 우선순위 설정 (시간 절약 효과 큰 것부터)

2. **작은 것부터 시작**
   - 가장 간단한 자동화부터 구현
   - 성공 경험 쌓기
   - 점진적으로 확장

3. **팀과 공유**
   - 자동화 성과 공유
   - 다른 팀원들 교육
   - 자동화 문화 확산

### 지속적인 학습

1. **주간 n8n 시간 설정**
   - 매주 1시간씩 새로운 노드 학습
   - 커뮤니티 워크플로우 탐색
   - 자신만의 라이브러리 구축

2. **프로젝트 확장**
   - 더 복잡한 워크플로우 도전
   - 여러 워크플로우 연결
   - 커스텀 노드 개발 고려

3. **커뮤니티 기여**
   - 유용한 워크플로우 공유
   - 다른 사용자 돕기
   - 피드백 주고받기

## 🆘 도움이 필요할 때

### 문제 해결 순서

1. **공식 문서 검색**: https://docs.n8n.io
2. **커뮤니티 포럼 검색**: https://community.n8n.io
3. **GitHub Issues 확인**: https://github.com/n8n-io/n8n/issues
4. **Discord에서 질문**: https://discord.gg/n8n

### 질문하는 방법

좋은 질문을 하면 더 빠른 답변을 받을 수 있습니다:

```
✅ 좋은 질문 예시:

제목: Google Sheets Append 노드에서 "Permission denied" 오류

환경:
- n8n 버전: 1.0.0
- 클라우드/셀프호스팅: 클라우드

문제:
Google Sheets Append 노드를 실행하면 "Permission denied" 오류가 발생합니다.

시도한 것:
1. 서비스 계정에 시트 편집 권한 부여 확인
2. 인증 정보 재생성 및 재등록
3. 시트 이름 정확성 확인

스크린샷:
[에러 메시지 스크린샷]

워크플로우 JSON:
[간단한 재현 가능한 워크플로우]
```

## ✅ 최종 체크리스트

실습을 완료하셨나요? 다음을 확인해보세요:

### 기술 역량
- [ ] n8n 인터페이스를 능숙하게 사용할 수 있다
- [ ] Webhook, HTTP Request, 기본 노드들을 이해했다
- [ ] Google Sheets API를 연동하고 데이터를 처리할 수 있다
- [ ] 웹 스크래핑 기본 개념과 윤리를 이해했다
- [ ] OpenAI API를 활용하여 AI 기능을 구현할 수 있다
- [ ] 복잡한 워크플로우를 설계하고 구현할 수 있다

### 실무 적용
- [ ] 현재 업무에서 자동화 가능한 작업을 3개 이상 식별했다
- [ ] 최소 1개의 실제 업무 워크플로우를 구현했다
- [ ] 에러 처리와 모니터링을 고려한 설계를 할 수 있다
- [ ] 워크플로우를 문서화하고 공유할 수 있다

### 지속 가능성
- [ ] n8n 커뮤니티에 가입하고 활동을 시작했다
- [ ] 정기적으로 학습할 계획을 세웠다
- [ ] 팀 또는 조직에 자동화 문화를 확산할 방법을 생각했다

---

## 🎉 축하합니다!

n8n 워크플로우 자동화 실습을 완료하셨습니다!

이제 여러분은:
- ✅ 코딩 없이 복잡한 자동화를 구현할 수 있습니다
- ✅ AI를 업무에 실제로 활용할 수 있습니다
- ✅ 반복 작업을 자동화하여 시간을 절약할 수 있습니다
- ✅ 생산성을 크게 향상시킬 수 있습니다

**"반복은 기계에게, 창조는 인간에게"**

자동화를 통해 더 가치 있는 일에 집중하세요!

---

## 📞 연락처 및 피드백

- **이슈 리포트**: GitHub Issues
- **개선 제안**: Pull Request 환영
- **질문**: n8n 커뮤니티 포럼

**Happy Automating! 🚀**
