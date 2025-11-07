#!/usr/bin/env node

/**
 * 파일명 유사도 계산기
 * 사용법: node similarity-calculator.js "파일명1.pdf" "파일명2.pdf"
 */

/**
 * Levenshtein Distance 알고리즘
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
 * 유사도 계산 (0-100%)
 */
function calculateSimilarity(str1, str2) {
  // 확장자 제거
  const name1 = str1.replace(/\.[^/.]+$/, "");
  const name2 = str2.replace(/\.[^/.]+$/, "");

  const longer = name1.length > name2.length ? name1 : name2;
  const shorter = name1.length > name2.length ? name2 : name1;

  if (longer.length === 0) {
    return 100.0;
  }

  const distance = levenshteinDistance(longer, shorter);
  const similarity = ((longer.length - distance) / longer.length) * 100;

  return Math.round(similarity * 100) / 100;
}

/**
 * Jaccard 유사도 (단어 기반)
 */
function jaccardSimilarity(str1, str2) {
  // 파일명을 단어로 분할 (공백, 하이픈, 언더스코어 기준)
  const words1 = new Set(str1.toLowerCase().split(/[\s\-_]+/));
  const words2 = new Set(str2.toLowerCase().split(/[\s\-_]+/));

  // 교집합
  const intersection = new Set([...words1].filter(x => words2.has(x)));

  // 합집합
  const union = new Set([...words1, ...words2]);

  if (union.size === 0) return 100;

  return Math.round((intersection.size / union.size) * 100 * 100) / 100;
}

/**
 * 날짜/버전 패턴 감지
 */
function detectVersionPattern(filename) {
  const patterns = {
    date: /\d{4}[-_]?\d{2}[-_]?\d{2}/,
    version: /v\d+(\.\d+)*/i,
    revision: /rev\d+|r\d+/i,
    final: /final|최종/i,
    draft: /draft|초안/i
  };

  const matches = {};
  for (const [type, pattern] of Object.entries(patterns)) {
    const match = filename.match(pattern);
    if (match) {
      matches[type] = match[0];
    }
  }

  return matches;
}

/**
 * 고급 유사도 분석
 */
function advancedSimilarity(file1, file2) {
  // 1. Levenshtein 유사도
  const levenshteinScore = calculateSimilarity(file1, file2);

  // 2. Jaccard 유사도 (단어 기반)
  const jaccardScore = jaccardSimilarity(file1, file2);

  // 3. 버전/날짜 패턴 감지
  const patterns1 = detectVersionPattern(file1);
  const patterns2 = detectVersionPattern(file2);

  // 버전 패턴 제거 후 유사도
  let cleanFile1 = file1;
  let cleanFile2 = file2;

  Object.values(patterns1).forEach(pattern => {
    cleanFile1 = cleanFile1.replace(pattern, '');
  });
  Object.values(patterns2).forEach(pattern => {
    cleanFile2 = cleanFile2.replace(pattern, '');
  });

  const cleanSimilarity = calculateSimilarity(cleanFile1, cleanFile2);

  // 4. 최종 점수 (가중 평균)
  const finalScore = Math.round(
    (levenshteinScore * 0.3 + jaccardScore * 0.3 + cleanSimilarity * 0.4) * 100
  ) / 100;

  return {
    levenshtein_similarity: levenshteinScore,
    jaccard_similarity: jaccardScore,
    clean_similarity: cleanSimilarity,
    final_score: finalScore,
    file1_patterns: patterns1,
    file2_patterns: patterns2,
    likely_same_document: finalScore >= 70,
    likely_version_relationship: cleanSimilarity >= 90 && (Object.keys(patterns1).length > 0 || Object.keys(patterns2).length > 0)
  };
}

// CLI 실행
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log('사용법: node similarity-calculator.js "파일명1" "파일명2"');
    console.log('\n예제:');
    console.log('  node similarity-calculator.js "보고서_2024_v1.pdf" "보고서_2024_v2.pdf"');
    console.log('  node similarity-calculator.js "제안서_초안.docx" "제안서_최종.docx"');
    process.exit(1);
  }

  const [file1, file2] = args;

  console.log('\n파일명 유사도 분석 결과:\n');
  console.log(`파일 1: ${file1}`);
  console.log(`파일 2: ${file2}\n`);

  const result = advancedSimilarity(file1, file2);

  console.log('=== 유사도 점수 ===');
  console.log(`Levenshtein 유사도: ${result.levenshtein_similarity}%`);
  console.log(`Jaccard 유사도: ${result.jaccard_similarity}%`);
  console.log(`패턴 제거 후 유사도: ${result.clean_similarity}%`);
  console.log(`\n최종 점수: ${result.final_score}%\n`);

  console.log('=== 패턴 감지 ===');
  console.log('파일 1 패턴:', Object.keys(result.file1_patterns).length > 0 ? result.file1_patterns : '없음');
  console.log('파일 2 패턴:', Object.keys(result.file2_patterns).length > 0 ? result.file2_patterns : '없음');
  console.log('');

  console.log('=== 분석 결과 ===');
  if (result.likely_version_relationship) {
    console.log('✅ 동일 문서의 다른 버전일 가능성이 높습니다.');
  } else if (result.likely_same_document) {
    console.log('✅ 유사한 문서입니다 (비교 분석 권장)');
  } else {
    console.log('❌ 서로 다른 문서입니다.');
  }
  console.log('');
}

// 모듈로 export
module.exports = {
  levenshteinDistance,
  calculateSimilarity,
  jaccardSimilarity,
  detectVersionPattern,
  advancedSimilarity
};
