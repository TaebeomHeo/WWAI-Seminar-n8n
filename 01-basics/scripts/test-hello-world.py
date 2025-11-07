#!/usr/bin/env python3

"""
n8n Hello World 워크플로우 테스트 스크립트 (Python)
사용법: python test-hello-world.py YOUR_WEBHOOK_URL
"""

import sys
import json
import urllib.request
import urllib.error

# 색상 코드
class Colors:
    GREEN = '\033[0;32m'
    BLUE = '\033[0;34m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

WEBHOOK_URL = sys.argv[1] if len(sys.argv) > 1 else 'https://your-n8n-instance.app.n8n.cloud/webhook/hello'

def make_request(url):
    """HTTP GET 요청"""
    try:
        with urllib.request.urlopen(url) as response:
            data = response.read()
            return json.loads(data.decode('utf-8'))
    except urllib.error.URLError as e:
        return {'error': str(e)}
    except json.JSONDecodeError:
        return {'error': 'Invalid JSON response'}

def run_tests():
    """테스트 실행"""
    print(f"{Colors.BLUE}=== n8n Hello World 테스트 ==={Colors.NC}\n")

    # 테스트 1: 기본 요청
    print(f"{Colors.GREEN}테스트 1: 기본 GET 요청{Colors.NC}")
    response = make_request(WEBHOOK_URL)
    print(json.dumps(response, indent=2, ensure_ascii=False))
    print()

    # 테스트 2: Query Parameter 포함
    print(f"{Colors.GREEN}테스트 2: Query Parameter 포함{Colors.NC}")
    response = make_request(f"{WEBHOOK_URL}?name=홍길동")
    print(json.dumps(response, indent=2, ensure_ascii=False))
    print()

    # 테스트 3: 여러 Parameter
    print(f"{Colors.GREEN}테스트 3: 여러 Query Parameters{Colors.NC}")
    response = make_request(f"{WEBHOOK_URL}?name=홍길동&city=서울")
    print(json.dumps(response, indent=2, ensure_ascii=False))
    print()

    print(f"{Colors.BLUE}=== 테스트 완료 ==={Colors.NC}")

if __name__ == '__main__':
    run_tests()
