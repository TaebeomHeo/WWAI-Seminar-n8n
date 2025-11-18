#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
일정 추출 테스트 스크립트 (Python)

실행 방법: python test-schedule-extraction.py
"""

import json
import os
import time
from datetime import datetime
from pathlib import Path

# 색상 코드
class Colors:
    BLUE = '\033[34m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    RED = '\033[31m'
    RESET = '\033[0m'

def print_header():
    """헤더 출력"""
    print(f"{Colors.BLUE}========================================{Colors.RESET}")
    print(f"{Colors.BLUE}일정 추출 테스트 스크립트 (Python){Colors.RESET}")
    print(f"{Colors.BLUE}========================================\n{Colors.RESET}")

def send_to_webhook(payload):
    """
    Webhook 호출 함수

    실제 환경에서는 requests 라이브러리 사용:
    import requests
    response = requests.post(WEBHOOK_URL, json=payload)
    return response.json()
    """
    # 테스트 모드
    return {"success": True, "message": "Test mode - webhook not called"}

def process_email(email_file, sample_dir):
    """이메일 처리 함수"""
    file_path = os.path.join(sample_dir, email_file)

    if not os.path.exists(file_path):
        print(f"{Colors.RED}❌ 파일을 찾을 수 없습니다: {file_path}{Colors.RESET}")
        return

    print(f"{Colors.GREEN}처리 중: {email_file}{Colors.RESET}")

    # 이메일 내용 읽기
    with open(file_path, 'r', encoding='utf-8') as f:
        email_content = f.read()

    # JSON 페이로드 생성
    payload = {
        "email_content": email_content,
        "source_file": email_file,
        "received_at": datetime.now().isoformat()
    }

    # Webhook 호출
    response = send_to_webhook(payload)

    # 결과 출력
    print(f"{Colors.BLUE}📤 Webhook 페이로드:{Colors.RESET}")
    print(json.dumps(payload, ensure_ascii=False, indent=2))

    print(f"{Colors.GREEN}✅ 처리 완료\n{Colors.RESET}")
    print("---")

def main():
    """메인 실행 함수"""
    print_header()

    # n8n webhook URL (사용자가 수정해야 함)
    WEBHOOK_URL = "https://your-n8n-instance.com/webhook/schedule-intelligence"

    # 샘플 이메일 디렉토리
    script_dir = Path(__file__).parent
    sample_dir = script_dir.parent / 'data' / 'sample-emails'

    # 이메일 파일 목록
    email_files = [
        'meeting-simple.txt',
        'meeting-vague.txt',
        'deadline.txt',
        'event.txt'
    ]

    print(f"{Colors.YELLOW}📧 샘플 이메일 처리 시작...\n{Colors.RESET}")

    for email_file in email_files:
        process_email(email_file, sample_dir)
        # 다음 이메일 처리 전 대기
        time.sleep(1)

    print(f"\n{Colors.GREEN}========================================{Colors.RESET}")
    print(f"{Colors.GREEN}모든 테스트 완료!{Colors.RESET}")
    print(f"{Colors.GREEN}========================================\n{Colors.RESET}")

    print(f"{Colors.YELLOW}💡 실제 테스트를 위해:{Colors.RESET}")
    print("1. WEBHOOK_URL을 실제 n8n webhook 주소로 변경하세요")
    print("2. send_to_webhook 함수에서 requests 라이브러리 사용 (line 36-39)")
    print("3. requests 설치: pip install requests")
    print("")

if __name__ == "__main__":
    main()
