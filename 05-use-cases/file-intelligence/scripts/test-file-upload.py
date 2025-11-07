#!/usr/bin/env python3

"""
Google Drive 테스트 파일 업로드 스크립트
사용법: python test-file-upload.py --folder-id FOLDER_ID --file sample.pdf
"""

import argparse
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# Google Drive API 스코프
SCOPES = ['https://www.googleapis.com/auth/drive']

def upload_file(service_account_file, folder_id, file_path):
    """Google Drive에 파일 업로드"""

    # 서비스 계정 인증
    credentials = service_account.Credentials.from_service_account_file(
        service_account_file, scopes=SCOPES)

    # Drive API 서비스 생성
    service = build('drive', 'v3', credentials=credentials)

    # 파일 메타데이터
    file_metadata = {
        'name': os.path.basename(file_path),
        'parents': [folder_id]
    }

    # 미디어 파일
    media = MediaFileUpload(file_path, resumable=True)

    # 파일 업로드
    print(f'📤 파일 업로드 중: {os.path.basename(file_path)}')

    file = service.files().create(
        body=file_metadata,
        media_body=media,
        fields='id, name, webViewLink, createdTime'
    ).execute()

    print(f'\n✅ 업로드 완료!')
    print(f'파일 ID: {file.get("id")}')
    print(f'파일명: {file.get("name")}')
    print(f'URL: {file.get("webViewLink")}')
    print(f'업로드 시간: {file.get("createdTime")}')

    return file

def create_test_files(output_dir='./test-files'):
    """테스트용 샘플 파일 생성"""

    os.makedirs(output_dir, exist_ok=True)

    # 샘플 1: 프로젝트 제안서
    sample1 = """
프로젝트 제안서

프로젝트명: AI 기반 자동화 시스템 구축
작성일: 2024-11-06
작성자: 홍길동

1. 프로젝트 개요
본 프로젝트는 n8n을 활용하여 업무 자동화 시스템을 구축하는 것을 목표로 합니다.

2. 주요 기능
- 문서 자동 분류
- AI 기반 요약
- 실시간 알림 시스템

3. 예상 효과
- 업무 시간 50% 절감
- 오류율 90% 감소
- 고객 만족도 향상

4. 일정
- 1주차: 요구사항 분석
- 2주차: 설계
- 3-4주차: 개발
- 5주차: 테스트 및 배포

5. 예산
총 예산: 50,000,000원
"""

    # 샘플 2: 프로젝트 제안서 v2 (수정본)
    sample2 = """
프로젝트 제안서 v2

프로젝트명: AI 기반 자동화 시스템 구축
작성일: 2024-11-07
작성자: 홍길동
검토자: 김철수

1. 프로젝트 개요
본 프로젝트는 n8n과 OpenAI를 활용하여 업무 자동화 시스템을 구축하는 것을 목표로 합니다.
(수정: OpenAI 추가 명시)

2. 주요 기능
- 문서 자동 분류 및 태깅
- AI 기반 요약 및 비교 분석 (신규)
- 실시간 알림 시스템 (Slack, Email 통합)
- 유사 문서 자동 감지 (신규)

3. 예상 효과
- 업무 시간 60% 절감 (상향 조정)
- 오류율 95% 감소 (상향 조정)
- 고객 만족도 향상
- 문서 관리 효율성 200% 증대 (신규)

4. 일정
- 1주차: 요구사항 분석 및 PoC
- 2주차: 상세 설계
- 3-5주차: 개발 및 단계별 테스트
- 6주차: 통합 테스트 및 배포
(수정: 일정 1주 연장)

5. 예산
총 예산: 55,000,000원
(수정: 기능 추가로 예산 10% 증액)
"""

    # 샘플 3: 회의록
    sample3 = """
월간 팀 회의록

일시: 2024-11-06 14:00-15:30
장소: 회의실 A
참석자: 홍길동, 김철수, 이영희, 박민수

안건:
1. Q4 실적 검토
   - 목표 대비 95% 달성
   - 주요 성과: 신규 고객 10개사 확보

2. 자동화 프로젝트 진행 현황
   - 현재 진행률: 70%
   - 이슈: API 한도 문제 발생 → 해결 완료
   - 다음 단계: 사용자 교육

3. 차기 분기 계획
   - 목표: 전 부서 자동화 확대
   - 예산: 100,000,000원 요청

결정 사항:
- 자동화 시스템 전사 확대 승인
- 추가 인력 2명 채용 예정
- 다음 회의: 2024-12-06

액션 아이템:
- 홍길동: 사용자 교육 자료 준비 (11/13까지)
- 김철수: 예산 승인 요청서 작성 (11/10까지)
- 이영희: 인력 채용 공고 게시 (11/08까지)
"""

    # 파일 저장
    files = {
        '프로젝트_제안서_v1.txt': sample1,
        '프로젝트_제안서_v2.txt': sample2,
        '팀회의록_2024_11_06.txt': sample3
    }

    created_files = []
    for filename, content in files.items():
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        created_files.append(filepath)
        print(f'✅ 생성됨: {filepath}')

    return created_files

def main():
    parser = argparse.ArgumentParser(description='Google Drive 테스트 파일 업로드')
    parser.add_argument('--credentials', help='서비스 계정 JSON 파일 경로')
    parser.add_argument('--folder-id', help='업로드할 Google Drive 폴더 ID')
    parser.add_argument('--file', help='업로드할 파일 경로')
    parser.add_argument('--create-samples', action='store_true', help='샘플 파일 생성')

    args = parser.parse_args()

    # 샘플 파일 생성
    if args.create_samples:
        print('📝 샘플 테스트 파일 생성 중...\n')
        files = create_test_files()
        print(f'\n✅ {len(files)}개의 샘플 파일이 생성되었습니다.')
        print('\n사용법:')
        print('python test-file-upload.py --credentials service-account.json --folder-id FOLDER_ID --file ./test-files/프로젝트_제안서_v1.txt')
        return

    # 필수 인자 확인
    if not args.credentials or not args.folder_id or not args.file:
        parser.print_help()
        print('\n먼저 샘플 파일을 생성하려면:')
        print('python test-file-upload.py --create-samples')
        return

    # 파일 업로드
    upload_file(args.credentials, args.folder_id, args.file)

if __name__ == '__main__':
    main()
