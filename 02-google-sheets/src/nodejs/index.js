const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const { google } = require('googleapis');

// --- CONFIGURATION ---

const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());

// Google API 스코프 및 인증 파일 설정
const SCOPES = ['https://www.googleapis.com/auth/spreadsheets'];
// 부모 디렉토리의 credentials.json 파일을 참조
const CREDENTIALS_FILE = path.join(__dirname, '..', 'credentials.json');

let spreadsheetId;
let auth;

// --- GOOGLE SHEETS AUTHENTICATION ---

async function loadCredentials() {
  try {
    const content = await fs.readFile(CREDENTIALS_FILE);
    const config = JSON.parse(content);

    const gcpServiceAccount = config.google_service_account;
    if (!gcpServiceAccount) {
      throw new Error('`google_service_account` not found in credentials.json');
    }

    spreadsheetId = config.spreadsheet_id;
    if (!spreadsheetId) {
      throw new Error('`spreadsheet_id` not found in credentials.json');
    }

    // JWT 클라이언트 생성
    auth = new google.auth.GoogleAuth({
      credentials: gcpServiceAccount,
      scopes: SCOPES,
    });
    
    // 인증 테스트 (선택 사항)
    const client = await auth.getClient();
    const sheets = google.sheets({ version: 'v4', auth: client });
    await sheets.spreadsheets.get({ spreadsheetId });

    console.log('Successfully loaded and verified Google Sheets credentials.');
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.error(`ERROR: Credentials file not found at ${CREDENTIALS_FILE}`);
      console.error("Please create it based on 'credentials.json.example' and add your GCP service account key and spreadsheet ID.");
    } else {
      console.error('An error occurred during credential loading:', error.message);
    }
    return false;
  }
}

// --- API ENDPOINTS ---

app.get('/', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Sales Tracker API is running.' });
});

app.post('/sales', async (req, res) => {
  if (!auth || !spreadsheetId) {
    return res.status(500).json({ success: false, message: 'Credentials not loaded. Check server startup logs.' });
  }

  try {
    // 1. Webhook으로 데이터 수신
    const data = req.body;
    console.log(`Received sales data: ${JSON.stringify(data)}`);

    // 2. 데이터 정리 및 추가 (Set 노드 역할)
    const customerName = data.customer_name || 'N/A';
    const product = data.product || 'N/A';
    const amount = parseInt(data.amount || 0, 10);
    const timestamp = new Date().toLocaleString('ko-KR', { timeZone: 'Asia/Seoul' });
    const status = data.status || '진행중';

    // Google Sheets에 기록할 행 데이터
    const rowData = [timestamp, customerName, product, amount, status];

    // 3. Google Sheets에 데이터 추가 (Append)
    const client = await auth.getClient();
    const sheets = google.sheets({ version: 'v4', auth: client });
    
    const request = {
      spreadsheetId: spreadsheetId,
      range: '매출관리!A1',
      valueInputOption: 'USER_ENTERED',
      insertDataOption: 'INSERT_ROWS',
      resource: {
        values: [rowData],
      },
    };

    const response = await sheets.spreadsheets.values.append(request);
    console.log(`Appended data to sheet: ${response.data.updates.updatedRange}`);

    // 4. 조건부 로직 (IF 노드 역할)
    if (amount >= 100000) {
      // Slack/Discord 알림 대신 콘솔에 메시지 출력
      console.log(`🎉 대형 거래 발생! 고객: ${customerName}, 금액: ${amount}원`);
      // 여기에 실제 알림 로직을 추가할 수 있습니다.
    }

    // 5. 성공 응답 반환
    const responseData = {
      date: timestamp,
      customer_name: customerName,
      product: product,
      amount: amount,
      status: status,
    };
    
    res.status(200).json({
      success: true,
      message: '매출 데이터가 성공적으로 기록되었습니다',
      data: responseData,
    });

  } catch (err) {
    console.error('Google Sheets API Error:', err.message);
    res.status(500).json({ success: false, message: 'Google Sheets API Error', error: err.message });
  }
});


// --- RUN SERVER ---

async function startServer() {
  const credentialsLoaded = await loadCredentials();
  if (credentialsLoaded) {
    app.listen(PORT, () => {
      console.log(`Server is running on http://localhost:${PORT}`);
    });
  } else {
    console.error('Server startup failed due to credential loading errors.');
    // 프로세스를 종료하여 서버가 불완전한 상태로 실행되는 것을 방지
    process.exit(1);
  }
}

startServer();
