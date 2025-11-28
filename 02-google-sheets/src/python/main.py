import os
import json
from datetime import datetime

import uvicorn
from fastapi import FastAPI, Request, HTTPException
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# --- CONFIGURATION ---

# FastAPI 앱 초기화
app = FastAPI()

# Google API 스코프 및 인증 파일 설정
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
# 부모 디렉토리의 credentials.json 파일을 참조
CREDENTIALS_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'credentials.json')

# Google Sheets 설정을 위한 전역 변수
spreadsheet_id = None
creds = None

# --- GOOGLE SHEETS AUTHENTICATION ---

@app.on_event("startup")
def load_credentials():
    """
    애플리케이션 시작 시 `credentials.json` 파일에서 인증 정보를 로드합니다.
    파일이 없거나 `spreadsheet_id`가 설정되지 않은 경우 오류를 발생시킵니다.
    """
    global creds, spreadsheet_id
    try:
        with open(CREDENTIALS_FILE, 'r') as f:
            config = json.load(f)
        
        # Google 서비스 계정 정보 로드
        gcp_creds_dict = config.get("google_service_account")
        if not gcp_creds_dict:
            raise HTTPException(status_code=500, detail="`google_service_account` not found in credentials.json")
        creds = service_account.Credentials.from_service_account_info(gcp_creds_dict, scopes=SCOPES)
        
        # 스프레드시트 ID 로드
        spreadsheet_id = config.get("spreadsheet_id")
        if not spreadsheet_id:
            raise HTTPException(status_code=500, detail="`spreadsheet_id` not found in credentials.json")

        print("Successfully loaded Google Sheets credentials.")

    except FileNotFoundError:
        print(f"ERROR: Credentials file not found at {CREDENTIALS_FILE}")
        print("Please create it based on 'credentials.json.example' and add your GCP service account key and spreadsheet ID.")
        # 실제 운영 환경에서는 아래 라인의 주석을 해제하여 서버 시작을 막을 수 있습니다.
        # raise HTTPException(status_code=500, detail=f"Credentials file not found at {CREDENTIALS_FILE}")
    except Exception as e:
        print(f"An error occurred during credential loading: {e}")
        # raise HTTPException(status_code=500, detail=str(e))


# --- API ENDPOINTS ---

@app.get("/")
def read_root():
    """
    서버 상태를 확인하기 위한 기본 엔드포인트입니다.
    """
    return {"status": "ok", "message": "Sales Tracker API is running."}


@app.post("/sales")
async def record_sale(request: Request):
    """
    '/sales' 경로로 POST 요청을 받아 매출 데이터를 Google Sheets에 기록합니다.
    n8n 워크플로우 '01-sales-tracker'의 로직을 재현합니다.
    """
    if not creds or not spreadsheet_id:
        raise HTTPException(status_code=500, detail="Credentials not loaded. Check server startup logs.")

    try:
        # 1. Webhook으로 데이터 수신 (FastAPI가 자동으로 처리)
        data = await request.json()
        print(f"Received sales data: {data}")

        # 2. 데이터 정리 및 추가 (Set 노드 역할)
        customer_name = data.get("customer_name", "N/A")
        product = data.get("product", "N/A")
        amount = int(data.get("amount", 0))
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        status = data.get("status", "진행중")

        # Google Sheets에 기록할 행 데이터
        row_data = [timestamp, customer_name, product, amount, status]

        # 3. Google Sheets에 데이터 추가 (Append)
        service = build('sheets', 'v4', credentials=creds)
        sheet = service.spreadsheets()
        
        # '매출관리' 시트에 데이터 추가
        range_name = '매출관리!A1'
        body = {'values': [row_data]}
        
        result = sheet.values().append(
            spreadsheetId=spreadsheet_id,
            range=range_name,
            valueInputOption='USER_ENTERED',
            insertDataOption='INSERT_ROWS',
            body=body
        ).execute()
        
        print(f"Appended data to sheet: {result}")

        # 4. 조건부 로직 (IF 노드 역할)
        if amount >= 100000:
            # Slack/Discord 알림 대신 콘솔에 메시지 출력
            print(f"🎉 대형 거래 발생! 고객: {customer_name}, 금액: {amount}원")
            # 여기에 실제 알림 로직(예: Slack, Discord API 호출)을 추가할 수 있습니다.

        # 5. 성공 응답 반환
        response_data = {
            "date": timestamp,
            "customer_name": customer_name,
            "product": product,
            "amount": amount,
            "status": status
        }
        return {
            "success": True,
            "message": "매출 데이터가 성공적으로 기록되었습니다",
            "data": response_data
        }

    except HttpError as err:
        print(f"Google Sheets API Error: {err}")
        raise HTTPException(status_code=500, detail=f"Google Sheets API Error: {err.resp.get('content', '')}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# --- RUN SERVER ---

if __name__ == "__main__":
    """
    `uvicorn main:app --reload` 명령어로 서버를 실행합니다.
    """
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
