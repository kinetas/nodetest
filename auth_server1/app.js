// ==================== 기본 내장/외부 모듈 ====================
const express = require('express');
const cors = require('cors');
require('dotenv').config();

// ==================== 미들웨어 & 유틸 ====================
const timeConverterMiddleware = require('./middleware/timeConverterMiddleware');

// ==================== 라우터 ====================
const authRoutes = require('./route/authRoute');

// ==================== 앱 초기화 ====================
const app = express();
const PORT = 3004;

// ==================== 공통 미들웨어 ====================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ==================== 라우팅 설정 ====================
app.use('/api/auth', timeConverterMiddleware, authRoutes);

// ==================== 라우팅: HTML 정적 페이지 ====================
// 헬스체크 라우트 추가 (Gateway에서 사용함)
app.get('/healthz', (req, res) => {
  res.status(200).send('OK');
});

// ==================== 404 처리 ====================
app.use((req, res) => {
  res.status(404).json({ message: '경로가 존재하지 않습니다.' });
});

// ==================== 서버 시작 ====================
app.listen(PORT, () => {
    console.log('Auth server listening on port 3004');
});