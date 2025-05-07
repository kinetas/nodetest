// ==================== 기본 내장/외부 모듈 ====================
const express = require('express');
const path = require('path');
const cors = require('cors');
const cron = require('node-cron');
require('dotenv').config();

// ==================== 미들웨어 & 유틸 ====================
const timeConverterMiddleware = require('./middleware/timeConverterMiddleware');
const loginRequired = require('./middleware/loginRequired'); // JWT 미들웨어 추가

// ==================== 라우터 ====================
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes');
const roomRoutes = require('./routes/roomRoutes');
const friendRoutes = require('./routes/friendRoutes');
const cVoteRoutes = require('./routes/cVoteRoutes');
const c_missionRoutes = require('./routes/c_missionRoutes');
const resultRoutes = require('./routes/resultRoutes'); 
const userInfoRoutes = require('./routes/userInfoRoutes');
const recommendationMissionRoutes = require('./routes/recommendationMissionRoutes');
const aiRoutes = require('./routes/aiRoutes');
const authRoutes = require('./routes/authRoutes');//MSA 적용 시 삭제

// ==================== 컨트롤러 (Cron용 함수 등) ====================
const { checkMissionStatus } = require('./controllers/c_missionController');
const { checkMissionDeadline } = require('./controllers/missionController');
const { checkAndUpdateMissions } = require('./controllers/cVoteController');
const roomController = require('./controllers/roomController');

// ==================== 앱 초기화 ====================
const app = express();
const PORT = 3000;

// ==================== 공통 미들웨어 ====================
app.use(cors());  // 모든 출처?�� ?���????�� ?��?��
app.use(cors({
    origin: 'http://27.113.11.48:3000',
    allowedHeaders: ['Authorization', 'Content-Type'],
    // credentials: true // 쿠키 방식 사용 시 필요, 지금은 무관
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
  
// ==================== 정적 파일 제공 ====================
// Static folder to serve the HTML file
app.use(express.static('public'));

// ==================== 라우팅 설정 ====================
app.use('/api/user-info', timeConverterMiddleware, userInfoRoutes);
app.use('/dashboard', timeConverterMiddleware, missionRoutes);
app.use('/api/rooms', timeConverterMiddleware, loginRequired, roomRoutes);
app.use('/api/missions', timeConverterMiddleware, loginRequired, missionRoutes);
app.use('/result', timeConverterMiddleware, loginRequired, resultRoutes);
app.use('/dashboard/friends', timeConverterMiddleware, loginRequired, friendRoutes);
app.use('/api/cVote', timeConverterMiddleware, loginRequired, cVoteRoutes);
app.use('/api/comumunity_missions', timeConverterMiddleware, loginRequired, c_missionRoutes);
app.use('/chat', timeConverterMiddleware, loginRequired, chatRoutes);
app.use('/api/recommendationMission', recommendationMissionRoutes); //미션 추천 라우트
app.use('/api/ai', aiRoutes);
// app.use('/api/auth', timeConverterMiddleware, authRoutes);//MSA적용 시 삭제

// ==================== 라우팅: HTML 정적 페이지 ====================
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});
app.get('/community_missions', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'community_missions.html'));
});
app.get('/user-info', loginRequired, (req, res) => {
    res.json({ userId: req.currentUserId });    //JWT 토큰기반
});
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html'));
});
app.get('/rooms', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'rooms.html'));
});
app.get('/cVote', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'cVote.html'));
});
app.get('/chat', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'chat.html'));
});
app.get('/result', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'result.html')); // result.html 경로
});
app.get('/printmissionlist', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'printmissionlist.html')); // printmissionlist.html 경로
});
app.get('/cVote/details/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'voteDetails.html'));
});
// 추천 미션 페이지 라우트
app.get('/recommendationMission', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'recommendationMission.html'));
});
app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  // ID찾기, PW변경 == MSA적용 시 삭제
});

// ==================== 기타 API ====================
app.post('/api/rooms/enter', roomController.enterRoom);

// ==================== 크론 작업 ====================
// cron.schedule('* * * * *', () => { // 매 분마다 실행
cron.schedule('0 0 * * *', () => { // 매일 자정에 실행
    console.log('미션 상태 확인');
    checkMissionStatus();
});
// cron.schedule('* * * * *', () => { // 매 분마다 실행
cron.schedule('0 0 * * *', () => { // 매일 자정에 실행
    console.log('마감 기한 체크');
    checkMissionDeadline();
});
cron.schedule('0 0 * * *', async () => { // 매일 자정에 실행
    console.log('미션 업데이트 체크');
    await checkAndUpdateMissions();
});

// ==================== FCM 알림 ====================
//const { sendNotificationController } = require('./controllers/sendNotificationController');
const {sendNotificationController} = require('./controllers/notificationController');
app.post('/api/send-notification', sendNotificationController);

// ==================== 404 처리 ====================
app.use((req, res) => {
    res.status(404).send('404 Not Found');
});

// ==================== 서버 시작 ====================
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});


/*
app.use((req, res, next) => {
    let rawBody = '';
    req.on('data', (chunk) => {
        rawBody += chunk.toString(); // 요청 Body를 문자열로 저장
    });

    req.on('end', () => {
        console.log(`[${req.method}] ${req.url} - Headers:`, req.headers);
        console.log(`Raw Body:`, rawBody);
        next();
    });
});
*/