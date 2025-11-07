# 프로젝트: 공유 폴더 파일 자동 분석 및 비교 시스템

## 📋 비즈니스 요구사항

**시나리오**: 팀 공유 폴더에 새로운 문서가 업로드될 때마다 자동으로 분석하고, 기존 유사 파일과 비교하여 팀원들에게 알림을 보내는 시스템

### 핵심 기능

1. **자동 모니터링**
   - 공유 폴더(Google Drive, OneDrive, NAS 등)의 새 파일 감지
   - Polling 또는 Webhook 방식 지원

2. **AI 기반 분석**
   - 문서 내용 자동 요약
   - 핵심 키워드 추출
   - 문서 타입 분류

3. **지능형 비교**
   - 파일명 유사도 검사
   - 기존 문서와의 차이점 분석
   - 버전 변경사항 요약

4. **다양한 알림 채널**
   - 이메일 발송
   - Slack 메시지
   - Microsoft Teams
   - 카카오톡 (선택)

---

## 🏗️ 시스템 아키텍처

### 옵션 1: Google Drive (Polling 방식)

```
[Schedule Trigger: 5분마다]
    ↓
[Google Drive - 새 파일 확인]
    ↓
[Code - 이미 처리된 파일 필터링]
    ↓
[Google Drive - 파일 다운로드]
    ↓
[AI 분석 - 문서 요약 생성]
    ↓
[파일명 유사도 검사]
    ↓
[IF - 유사 파일 존재?]
    ├─ Yes → [AI 비교 분석]
    └─ No → [요약만 진행]
    ↓
[결과 포맷팅]
    ↓
[병렬 알림]
    ├─ Email
    ├─ Slack
    └─ Google Sheets (로그)
```

### 옵션 2: Google Drive (Webhook 방식)

```
[Google Drive Trigger - File Created]
    ↓
[파일 메타데이터 추출]
    ↓
[파일 다운로드 및 텍스트 추출]
    ↓
[AI 분석 파이프라인]
    ↓
[알림 발송]
```

---

## 🚀 구현 가이드

### 1단계: Google Drive 연동 (Polling 방식)

#### 노드 1: Schedule Trigger
```
Cron Expression: */5 * * * *  (5분마다)
```

#### 노드 2: Google Drive - 최근 파일 조회
```javascript
// Google Drive 노드 설정
Operation: List
Folder: /팀공유/문서
Filters:
  - Modified Time: Last 10 minutes
  - MIME Type: application/pdf, application/vnd.openxmlformats-officedocument.*

// 또는 Query 사용
Query: "modifiedTime > '{{$now.minus(10, 'minutes').toISO()}}'"
```

#### 노드 3: Code - 중복 처리 방지
```javascript
// 이미 처리된 파일 ID를 Google Sheets 또는 n8n Static Data에 저장
const processedFiles = $node["Get Processed Files"].json.map(f => f.fileId);
const newFiles = $input.all();

const unprocessedFiles = newFiles.filter(file => {
  return !processedFiles.includes(file.json.id);
});

if (unprocessedFiles.length === 0) {
  // 새 파일이 없으면 워크플로우 중단
  return [];
}

return unprocessedFiles;
```

#### 노드 4: Google Drive - 파일 다운로드
```javascript
// Google Drive 노드
Operation: Download
File ID: ={{$json.id}}
Options:
  - Binary Property: data
```

#### 노드 5: Extract Document Content

**PDF 파일인 경우:**
```javascript
// HTTP Request to pdf.co 또는 다른 PDF 파싱 서비스
{
  "method": "POST",
  "url": "https://api.pdf.co/v1/pdf/convert/to/text",
  "headers": {
    "x-api-key": "YOUR_PDF_CO_API_KEY",
    "Content-Type": "application/json"
  },
  "body": {
    "url": "={{$json.webContentLink}}",
    "async": false
  }
}

// 또는 n8n의 Extract from File 노드 사용
```

**Word/Excel 파일인 경우:**
```javascript
// Google Drive를 Google Docs 형식으로 Export
Operation: Download
File ID: ={{$json.id}}
Options:
  - Export Format: text/plain (Word의 경우)
  - Export Format: text/csv (Excel의 경우)
```

---

### 2단계: AI 기반 문서 분석

#### 노드 6: OpenAI/Claude - 문서 요약

**GPT-4 Turbo 사용 (가장 똑똑한 모델)**
```javascript
// OpenAI 노드
{
  "model": "gpt-4-turbo-preview",  // 128K 컨텍스트
  "messages": [
    {
      "role": "system",
      "content": `당신은 전문 문서 분석가입니다. 다음 문서를 분석하여 JSON 형식으로 요약해주세요.

응답 형식:
{
  "title": "문서 제목 (추론)",
  "document_type": "보고서|제안서|계약서|기술문서|회의록|기타",
  "summary": "3-5문장으로 핵심 내용 요약",
  "key_points": ["핵심 포인트 1", "핵심 포인트 2", "핵심 포인트 3"],
  "keywords": ["키워드1", "키워드2", "키워드3"],
  "action_items": ["실행 항목 1", "실행 항목 2"],
  "mentioned_people": ["언급된 사람/조직 1", "언급된 사람/조직 2"],
  "dates": ["중요 날짜 1", "중요 날짜 2"],
  "urgency_level": "높음|보통|낮음",
  "confidence": 0-100
}`
    },
    {
      "role": "user",
      "content": `파일명: {{$json.name}}\n\n내용:\n{{$json.text_content}}`
    }
  ],
  "response_format": { "type": "json_object" },
  "temperature": 0.3
}
```

**대안: Claude 3.5 Sonnet 사용**
```javascript
// HTTP Request to Anthropic API
{
  "method": "POST",
  "url": "https://api.anthropic.com/v1/messages",
  "headers": {
    "x-api-key": "YOUR_ANTHROPIC_API_KEY",
    "anthropic-version": "2023-06-01",
    "Content-Type": "application/json"
  },
  "body": {
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 4096,
    "messages": [
      {
        "role": "user",
        "content": "파일명: {{$json.name}}\n\n내용:\n{{$json.text_content}}\n\n위 문서를 분석하여 요약해주세요..."
      }
    ]
  }
}
```

**대안: Google Gemini Pro 사용**
```javascript
// HTTP Request to Google AI API
{
  "method": "POST",
  "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent",
  "headers": {
    "Content-Type": "application/json"
  },
  "qs": {
    "key": "YOUR_GOOGLE_AI_API_KEY"
  },
  "body": {
    "contents": [{
      "parts": [{
        "text": "파일명: {{$json.name}}\n\n내용:\n{{$json.text_content}}\n\n위 문서를 분석하여 요약해주세요..."
      }]
    }],
    "generationConfig": {
      "temperature": 0.3,
      "topK": 40,
      "topP": 0.95
    }
  }
}
```

---

### 3단계: 파일명 유사도 검사 및 비교 분석

#### 노드 7: Google Sheets - 기존 파일 목록 조회
```javascript
// Google Sheets에 파일 로그 저장
// 컬럼: file_id, file_name, upload_date, summary, keywords

Operation: Read
Sheet: 파일로그
Range: A:E
```

#### 노드 8: Code - 파일명 유사도 계산

```javascript
/**
 * Levenshtein Distance 알고리즘으로 문자열 유사도 계산
 */
function levenshteinDistance(str1, str2) {
  const matrix = [];

  for (let i = 0; i <= str2.length; i++) {
    matrix[i] = [i];
  }

  for (let j = 0; j <= str1.length; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= str2.length; i++) {
    for (let j = 1; j <= str1.length; j++) {
      if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
        matrix[i][j] = matrix[i - 1][j - 1];
      } else {
        matrix[i][j] = Math.min(
          matrix[i - 1][j - 1] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j] + 1
        );
      }
    }
  }

  return matrix[str2.length][str1.length];
}

/**
 * 유사도 퍼센트 계산
 */
function similarity(str1, str2) {
  const longer = str1.length > str2.length ? str1 : str2;
  const shorter = str1.length > str2.length ? str2 : str1;

  if (longer.length === 0) {
    return 100.0;
  }

  const distance = levenshteinDistance(longer, shorter);
  return ((longer.length - distance) / longer.length) * 100;
}

// 현재 파일
const currentFile = $input.first().json;
const currentFileName = currentFile.name.replace(/\.[^/.]+$/, ""); // 확장자 제거

// 기존 파일들
const existingFiles = $node["Google Sheets"].json;

// 유사도 계산
const similarities = existingFiles.map(existingFile => {
  const existingFileName = existingFile.file_name.replace(/\.[^/.]+$/, "");
  const similarityScore = similarity(currentFileName, existingFileName);

  return {
    existing_file_id: existingFile.file_id,
    existing_file_name: existingFile.file_name,
    similarity_score: similarityScore,
    existing_summary: existingFile.summary,
    existing_keywords: existingFile.keywords
  };
});

// 유사도 70% 이상인 파일들만 필터링
const similarFiles = similarities
  .filter(s => s.similarity_score >= 70)
  .sort((a, b) => b.similarity_score - a.similarity_score);

return {
  ...currentFile,
  similar_files: similarFiles,
  has_similar_files: similarFiles.length > 0,
  most_similar: similarFiles[0] || null
};
```

#### 노드 9: IF - 유사 파일 존재 여부
```javascript
Condition: ={{$json.has_similar_files}} equals true
```

#### 노드 10: OpenAI - 비교 분석 (True 분기)

```javascript
// OpenAI 노드
{
  "model": "gpt-4-turbo-preview",
  "messages": [
    {
      "role": "system",
      "content": `두 문서를 비교 분석하는 전문가입니다.
다음 두 문서의 차이점을 분석하고 JSON 형식으로 응답해주세요.

응답 형식:
{
  "comparison_summary": "전체 비교 요약 (3-4문장)",
  "major_differences": [
    {
      "category": "내용|구조|톤|목적",
      "description": "차이점 설명",
      "severity": "높음|보통|낮음"
    }
  ],
  "common_elements": ["공통점 1", "공통점 2"],
  "new_in_current": ["신규 문서에만 있는 내용 1", "신규 문서에만 있는 내용 2"],
  "removed_from_previous": ["이전 문서에는 있었으나 제거된 내용 1", "제거된 내용 2"],
  "version_type": "major_update|minor_update|revision|completely_different",
  "recommendation": "이 문서에 대한 권장 사항"
}`
    },
    {
      "role": "user",
      "content": `=== 신규 문서 ===
파일명: {{$json.name}}
요약: {{$node["AI Summary"].json.summary}}

내용:
{{$json.text_content}}

=== 기존 유사 문서 ===
파일명: {{$json.most_similar.existing_file_name}}
유사도: {{$json.most_similar.similarity_score}}%
요약: {{$json.most_similar.existing_summary}}

두 문서를 비교 분석해주세요.`
    }
  ],
  "response_format": { "type": "json_object" },
  "temperature": 0.4
}
```

---

### 4단계: 결과 포맷팅 및 알림

#### 노드 11: Merge - 분석 결과 통합

```javascript
// Code 노드로 모든 데이터 병합
const fileData = $node["Google Drive Download"].json;
const aiSummary = JSON.parse($node["AI Summary"].json.message.content);
const comparisonData = $json.has_similar_files
  ? JSON.parse($node["AI Comparison"].json.message.content)
  : null;

return {
  // 파일 정보
  file_id: fileData.id,
  file_name: fileData.name,
  file_size: fileData.size,
  uploaded_by: fileData.owners?.[0]?.displayName || "Unknown",
  uploaded_at: fileData.createdTime,
  file_url: fileData.webViewLink,

  // AI 요약
  document_type: aiSummary.document_type,
  summary: aiSummary.summary,
  key_points: aiSummary.key_points,
  keywords: aiSummary.keywords,
  action_items: aiSummary.action_items,
  urgency_level: aiSummary.urgency_level,

  // 비교 분석 (있는 경우)
  has_comparison: comparisonData !== null,
  comparison: comparisonData,
  similar_file_name: $json.most_similar?.existing_file_name || null,
  similarity_score: $json.most_similar?.similarity_score || null,

  // 메타데이터
  processed_at: new Date().toISOString(),
  ai_model_used: "gpt-4-turbo-preview"
};
```

#### 노드 12: Email - 이메일 알림

```javascript
// Send Email 노드
{
  "to": "team@company.com",
  "subject": "🔔 새 문서 업로드: {{$json.file_name}}",
  "bodyType": "html",
  "body": `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: #4CAF50; color: white; padding: 20px; border-radius: 5px 5px 0 0; }
    .content { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; }
    .section { margin-bottom: 20px; }
    .label { font-weight: bold; color: #555; }
    .value { margin-top: 5px; }
    .urgent { background: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; }
    .comparison { background: #e3f2fd; border-left: 4px solid #2196F3; padding: 10px; margin-top: 15px; }
    .button {
      display: inline-block;
      padding: 10px 20px;
      background: #4CAF50;
      color: white;
      text-decoration: none;
      border-radius: 5px;
      margin-top: 15px;
    }
    ul { margin: 10px 0; padding-left: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>📄 새 문서가 업로드되었습니다</h2>
    </div>

    <div class="content">
      <!-- 파일 정보 -->
      <div class="section">
        <div class="label">📁 파일명:</div>
        <div class="value">{{$json.file_name}}</div>
      </div>

      <div class="section">
        <div class="label">👤 업로드:</div>
        <div class="value">{{$json.uploaded_by}} - {{$json.uploaded_at}}</div>
      </div>

      <div class="section">
        <div class="label">📊 문서 유형:</div>
        <div class="value">{{$json.document_type}}</div>
      </div>

      <!-- 긴급도 -->
      {{#if (eq $json.urgency_level "높음")}}
      <div class="urgent">
        ⚠️ <strong>긴급도: 높음</strong> - 즉시 검토가 필요합니다.
      </div>
      {{/if}}

      <!-- AI 요약 -->
      <div class="section">
        <div class="label">🤖 AI 요약:</div>
        <div class="value">{{$json.summary}}</div>
      </div>

      <!-- 핵심 포인트 -->
      <div class="section">
        <div class="label">🎯 핵심 포인트:</div>
        <ul>
          {{#each $json.key_points}}
            <li>{{this}}</li>
          {{/each}}
        </ul>
      </div>

      <!-- 실행 항목 -->
      {{#if $json.action_items.length}}
      <div class="section">
        <div class="label">✅ 실행 항목:</div>
        <ul>
          {{#each $json.action_items}}
            <li>{{this}}</li>
          {{/each}}
        </ul>
      </div>
      {{/if}}

      <!-- 키워드 -->
      <div class="section">
        <div class="label">🔖 키워드:</div>
        <div class="value">{{join $json.keywords ", "}}</div>
      </div>

      <!-- 비교 분석 (유사 파일이 있는 경우) -->
      {{#if $json.has_comparison}}
      <div class="comparison">
        <h3>🔍 유사 문서 비교 분석</h3>
        <p><strong>기존 문서:</strong> {{$json.similar_file_name}} (유사도: {{$json.similarity_score}}%)</p>

        <p><strong>비교 요약:</strong></p>
        <p>{{$json.comparison.comparison_summary}}</p>

        <p><strong>버전 타입:</strong> {{$json.comparison.version_type}}</p>

        {{#if $json.comparison.major_differences.length}}
        <p><strong>주요 차이점:</strong></p>
        <ul>
          {{#each $json.comparison.major_differences}}
            <li><strong>{{this.category}}:</strong> {{this.description}} (중요도: {{this.severity}})</li>
          {{/each}}
        </ul>
        {{/if}}

        {{#if $json.comparison.new_in_current.length}}
        <p><strong>신규 추가 내용:</strong></p>
        <ul>
          {{#each $json.comparison.new_in_current}}
            <li>{{this}}</li>
          {{/each}}
        </ul>
        {{/if}}

        <p><strong>권장사항:</strong> {{$json.comparison.recommendation}}</p>
      </div>
      {{/if}}

      <!-- 액션 버튼 -->
      <a href="{{$json.file_url}}" class="button">📄 문서 보기</a>
    </div>

    <div style="margin-top: 20px; text-align: center; color: #999; font-size: 12px;">
      <p>AI 분석 시스템 by n8n | 처리 시간: {{$json.processed_at}}</p>
    </div>
  </div>
</body>
</html>
  `
}
```

#### 노드 13: Slack - Slack 알림

```javascript
// Slack 노드
{
  "channel": "#team-documents",
  "text": "",  // 빈 문자열 (blocks 사용)
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "📄 새 문서 업로드 알림"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": `*파일명:*\n{{$json.file_name}}`
        },
        {
          "type": "mrkdwn",
          "text": `*업로드:*\n{{$json.uploaded_by}}`
        },
        {
          "type": "mrkdwn",
          "text": `*문서 유형:*\n{{$json.document_type}}`
        },
        {
          "type": "mrkdwn",
          "text": `*긴급도:*\n{{$json.urgency_level}}`
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": `*🤖 AI 요약:*\n{{$json.summary}}`
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": `*🎯 핵심 포인트:*\n{{#each $json.key_points}}- {{this}}\n{{/each}}`
      }
    },
    {{#if $json.has_comparison}}
    {
      "type": "divider"
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": `*🔍 유사 문서 발견!*\n기존 문서: \`{{$json.similar_file_name}}\` (유사도: {{$json.similarity_score}}%)\n\n*비교 분석:*\n{{$json.comparison.comparison_summary}}\n\n*버전 타입:* {{$json.comparison.version_type}}`
      }
    },
    {{/if}}
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "문서 열기"
          },
          "url": "{{$json.file_url}}",
          "style": "primary"
        }
      ]
    }
  ]
}
```

#### 노드 14: Google Sheets - 로그 저장

```javascript
// Google Sheets 노드
Operation: Append
Sheet: 파일로그

Data:
{
  "file_id": "={{$json.file_id}}",
  "file_name": "={{$json.file_name}}",
  "upload_date": "={{$json.uploaded_at}}",
  "uploaded_by": "={{$json.uploaded_by}}",
  "document_type": "={{$json.document_type}}",
  "summary": "={{$json.summary}}",
  "keywords": "={{$json.keywords.join(', ')}}",
  "urgency_level": "={{$json.urgency_level}}",
  "has_comparison": "={{$json.has_comparison}}",
  "similar_file": "={{$json.similar_file_name || 'N/A'}}",
  "processed_at": "={{$json.processed_at}}",
  "file_url": "={{$json.file_url}}"
}
```

---

## 📁 제공 파일

### workflows/
- `google-drive-polling.json` - Google Drive Polling 방식
- `google-drive-webhook.json` - Google Drive Webhook 방식
- `onedrive-monitoring.json` - Microsoft OneDrive 버전
- `dropbox-monitoring.json` - Dropbox 버전

### data/
- `sample-documents/` - 테스트용 샘플 문서들
- `processed-files-template.csv` - 처리된 파일 로그 템플릿

### scripts/
- `similarity-calculator.js` - 파일명 유사도 계산 스크립트
- `test-file-upload.py` - 테스트 파일 업로드 스크립트

---

## 🔧 다양한 옵션 및 커스터마이징

### 옵션 1: 모니터링 방식 선택

#### Polling 방식 (권장 - 안정적)
**장점:**
- 안정적이고 예측 가능
- 설정이 간단
- 대부분의 플랫폼 지원

**단점:**
- 실시간성이 떨어짐 (5-10분 지연)
- API 호출이 많을 수 있음

**설정:**
```javascript
// Schedule Trigger
Cron: */5 * * * *  // 5분마다

// Google Drive Query
modifiedTime > '{{$now.minus(10, 'minutes').toISO()}}'
```

#### Webhook 방식 (실시간)
**장점:**
- 실시간 알림
- API 호출 최소화

**단점:**
- 설정이 복잡
- 플랫폼별 지원 여부 확인 필요

**Google Drive Webhook 설정:**
```bash
# Google Drive API로 Watch 등록
POST https://www.googleapis.com/drive/v3/files/FILE_ID/watch
{
  "id": "unique-channel-id",
  "type": "web_hook",
  "address": "https://your-n8n-url/webhook/google-drive"
}
```

### 옵션 2: AI 모델 선택

#### GPT-4 Turbo (OpenAI)
```javascript
{
  "model": "gpt-4-turbo-preview",
  "장점": "가장 강력한 분석 능력, JSON 모드 지원",
  "단점": "비용이 높음 ($0.01/1K input tokens)",
  "적합한 경우": "복잡한 문서, 정확한 비교 분석 필요"
}
```

#### Claude 3.5 Sonnet (Anthropic)
```javascript
{
  "model": "claude-3-5-sonnet-20241022",
  "장점": "긴 문서 처리 우수 (200K tokens), 비용 효율적",
  "단점": "JSON 모드 미지원 (프롬프팅으로 극복 가능)",
  "적합한 경우": "긴 보고서, 기술 문서"
}
```

#### Gemini 1.5 Pro (Google)
```javascript
{
  "model": "gemini-1.5-pro",
  "장점": "무료 티어 제공, 멀티모달 지원",
  "단점": "일부 언어에서 정확도 낮을 수 있음",
  "적합한 경우": "예산이 제한적인 경우, 이미지 포함 문서"
}
```

### 옵션 3: 알림 채널 선택

#### 이메일
**언제 사용:**
- 공식적인 알림 필요
- 팀원이 이메일을 주로 사용
- 상세한 HTML 포맷 필요

#### Slack
**언제 사용:**
- 즉각적인 팀 협업 필요
- 인터랙티브 버튼 필요
- 빠른 피드백 원함

#### Microsoft Teams
**언제 사용:**
- 조직이 MS 365 사용
- Teams 중심 협업

#### 다중 채널
**권장 설정:**
```javascript
// 긴급도에 따라 다른 채널 사용
if (urgency_level === "높음") {
  // Slack + Email 둘 다
  sendSlack();
  sendEmail();
} else {
  // Slack만
  sendSlack();
}
```

### 옵션 4: 파일 타입별 처리

```javascript
// Code 노드에서 파일 타입별 분기
const fileType = $json.mimeType;

switch(fileType) {
  case 'application/pdf':
    // PDF 처리
    return { processor: 'pdf-parser', ...data };

  case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
    // Word 처리
    return { processor: 'word-extractor', ...data };

  case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
    // Excel 처리 - 첫 시트만 텍스트로 변환
    return { processor: 'excel-to-text', ...data };

  case 'text/plain':
    // 텍스트 파일
    return { processor: 'direct', ...data };

  case 'application/vnd.google-apps.document':
    // Google Docs - Export as text
    return { processor: 'gdocs-export', ...data };

  default:
    // 지원하지 않는 형식
    return { processor: 'unsupported', ...data };
}
```

---

## 💡 실전 팁 및 베스트 프랙티스

### 1. 비용 최적화

```javascript
// 문서 길이에 따라 AI 모델 선택
const contentLength = $json.text_content.length;

let model;
if (contentLength > 50000) {
  // 긴 문서: Claude 사용 (비용 효율적)
  model = "claude-3-5-sonnet-20241022";
} else if (contentLength > 10000) {
  // 중간 길이: GPT-4 Turbo
  model = "gpt-4-turbo-preview";
} else {
  // 짧은 문서: GPT-3.5 Turbo (가장 저렴)
  model = "gpt-3.5-turbo";
}
```

### 2. 에러 처리

```javascript
// PDF 파싱 실패 시 대체 방법
try {
  const pdfText = await parsePDF($json.data);
  return { text: pdfText, source: 'pdf-parser' };
} catch (error) {
  console.log('PDF 파싱 실패, OCR 시도...');

  try {
    // Google Vision API로 OCR
    const ocrText = await performOCR($json.data);
    return { text: ocrText, source: 'ocr' };
  } catch (ocrError) {
    // OCR도 실패하면 파일명과 메타데이터만 사용
    return {
      text: `[문서 내용을 추출할 수 없음]\n파일명: ${$json.name}`,
      source: 'metadata-only',
      error: true
    };
  }
}
```

### 3. 성능 최적화

```javascript
// 대용량 파일 처리 시 청크 분할
const MAX_CHUNK_SIZE = 30000;  // 토큰 제한 고려
const content = $json.text_content;

if (content.length > MAX_CHUNK_SIZE) {
  // 문서를 여러 청크로 분할
  const chunks = [];
  for (let i = 0; i < content.length; i += MAX_CHUNK_SIZE) {
    chunks.push(content.substring(i, i + MAX_CHUNK_SIZE));
  }

  // 각 청크를 요약
  const summaries = [];
  for (const chunk of chunks) {
    const summary = await summarizeChunk(chunk);
    summaries.push(summary);
  }

  // 모든 요약을 통합하여 최종 요약 생성
  const finalSummary = await summarize(summaries.join('\n\n'));
  return finalSummary;
}
```

### 4. 보안 고려사항

```javascript
// 민감한 문서 필터링
const sensitiveKeywords = ['기밀', '대외비', 'confidential', 'secret'];
const fileContent = $json.text_content.toLowerCase();

const isSensitive = sensitiveKeywords.some(keyword =>
  fileContent.includes(keyword)
);

if (isSensitive) {
  // 민감한 문서는 AI 처리하지 않고 관리자에게만 알림
  return {
    skip_ai: true,
    alert_level: 'high',
    message: '민감한 문서가 감지되었습니다. AI 처리를 건너뜁니다.',
    notify_admin: true
  };
}
```

---

## 🚀 확장 아이디어

### 1. 자동 태깅 시스템
```javascript
// AI로 자동 태그 생성 후 Google Drive에 적용
const tags = $json.keywords;

// Google Drive Labels API 사용
for (const tag of tags) {
  await applyLabel(fileId, tag);
}
```

### 2. 버전 관리 시스템
```javascript
// 유사 파일을 자동으로 버전으로 연결
if ($json.similarity_score > 90) {
  // 파일명에 버전 번호 추가
  const newName = `${baseFilename}_v${versionNumber}.${extension}`;
  await renameFile(fileId, newName);

  // 이전 버전과 링크 관계 저장
  await saveVersionRelationship(previousFileId, currentFileId);
}
```

### 3. 자동 폴더 정리
```javascript
// 문서 타입별로 자동 폴더 이동
const folderMap = {
  "보고서": "FOLDER_ID_REPORTS",
  "제안서": "FOLDER_ID_PROPOSALS",
  "계약서": "FOLDER_ID_CONTRACTS",
  "회의록": "FOLDER_ID_MINUTES"
};

const targetFolder = folderMap[$json.document_type];
if (targetFolder) {
  await moveFile(fileId, targetFolder);
}
```

### 4. 다국어 지원
```javascript
// 문서 언어 감지 후 번역
const detectedLanguage = await detectLanguage($json.text_content);

if (detectedLanguage !== 'ko') {
  const translated = await translateTo($json.text_content, 'ko');
  $json.translated_summary = translated;
}
```

---

**이전 단계**: [04. AI 자동화](../../04-ai-automation/README.md)
**메인 가이드**: [실무 유스케이스 목록](../README.md)
