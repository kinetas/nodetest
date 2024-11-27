const express = require('express');
const session = require('express-session'); //�꽭�뀡異붽��
const cron = require('node-cron');
const path = require('path');
const authRoutes = require('./routes/authRoutes'); // �씪�슦�듃 媛��졇�삤湲�
const missionRoutes = require('./routes/missionRoutes'); // 誘몄뀡 �씪�슦�듃 遺덈윭�삤湲�
const roomRoutes = require('./routes/roomRoutes');
const friendRoutes = require('./routes/friendRoutes');
const cVoteRoutes = require('./routes/cVoteRoutes');
const c_missionRoutes = require('./routes/c_missionRoutes');
const resultRoutes = require('./routes/resultRoutes'); // 결과 라우트 추가
const { checkMissionStatus } = require('./controllers/c_missionController');
const { checkMissionDeadline } = require('./controllers/missionController');
const db = require('./config/db');
const app = express();
const PORT = 3000;

// // ======== 수정 JWT ============
const jwt = require('jsonwebtoken'); // JWT 추가
// const requireAuth = require('./middleware/authMiddleware');

const cors = require('cors');
app.use(cors());  // 모든 출처의 요청을 허용

app.use(express.json()); // JSON �뙆�떛�쓣 �쐞�븳 誘몃뱾�썾�뼱 �꽕�젙
app.use(express.urlencoded({ extended: true })); // URL �씤肄붾뵫�맂 �뜲�씠�꽣 �뙆�떛�쓣 �쐞�븳 誘몃뱾�썾�뼱 �꽕�젙

// �꽭�뀡 �꽕�젙
app.use(session({
    secret: 'your_secret_key', // �꽭�뀡 �븫�샇�솕�뿉 �궗�슜�븷 �궎
    resave: false, // �꽭�뀡�쓣 �빆�긽 ����옣�븷吏� �뿬遺�
    saveUninitialized: false, // 珥덇린�솕�릺吏� �븡��� �꽭�뀡�쓣 ����옣�븷吏� �뿬遺�
    cookie: { maxAge: 1000 * 60 * 60 * 24 } // 荑좏궎�쓽 �쑀�슚 湲곌컙 (�뿬湲곗꽌�뒗 �븯猷�)
}));

// // ======== 수정 JWT ============
// // JSON 파싱과 URL 인코딩 설정
// app.use(cors());
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// Static folder to serve the HTML file
app.use(express.static('public'));


// 메시지 저장을 처리하는 API 엔드포인트 추가
app.post('/api/messages', (req, res) => {
    const { u1_id, u2_id, r_id, message_contents } = req.body;})
   /* // DB에 메시지 저장 로직 추가
    if (!u1_id || !u2_id || !r_id || !message_contents) {
        console.error('Missing required fields:', { u1_id, u2_id, r_id, message_contents});
        return res.status(400).json({ message: '필수 값이 누락되었습니다.' });
    }
    db.query(
        //'INSERT INTO r_message (u1_id, u2_id, r_id, message_contents, send_date) VALUES (?, ?, ?, ?, NOW())',
        'INSERT INTO r_message (u1_id, u2_id, r_id, message_contents) VALUES (?, ?, ?, ?)',
        [u1_id, u2_id, r_id, message_contents,],
        (err, result) => {
            if (err) {
                console.error('Error saving message to DB:', err);
                return res.status(500).json({ message: 'Failed to save message' });
            }

            // DB에 성공적으로 저장된 경우
            res.json({
                //r_id: r_id,
                message_contents: message_contents,
                send_date: new Date().toISOString().slice(0, 19).replace('T', ' '),
                u1_id: u1_id,
                //u2_id: u2_id
            });
        }
    );
});
*/



// �꽭�뀡 �씤利� 誘몃뱾�썾�뼱
const requireAuth = (req, res, next) => {
    if (!req.session.user) {
        return res.status(401).json({ message: '濡쒓렇�씤�씠 �븘�슂�빀�땲�떎.' });
    }
    next();
};



// �삁�떆: ����떆蹂대뱶 �씪�슦�듃 蹂댄샇
app.get('/dashboard', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
    // const userId = req.session.user.id;
    // res.json({ userId });
});
app.get('/community_missions', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'community_missions.html')); // community-missions.html 페이지 경로
});

// �쑀��� �젙蹂대�� 諛섑솚�븯�뒗 �씪�슦�듃 異붽��
app.get('/user-info', requireAuth, (req, res) => {
    res.json({ userId: req.session.user.id });
});



// 吏뱀갹夷섏Ł HTML �쉱�쉮占쏙옙�슃 �쉧吏앹㎏泥�
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html')); // ����떆蹂대뱶 HTML �뙆�씪
});
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html')); // �쉶�썝媛��엯 HTML �뙆�씪
});
app.get('/rooms', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'rooms.html'));
});

app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  //아이디/비밀번호 찾기 페이지
});
app.get('/cVote', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'cVote.html'));
});
app.get('/chat', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'chat.html')); //채팅 페이지
});

app.get('/result', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'result.html')); // result.html 경로
});

app.get('/printmissionlist', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'printmissionlist.html')); // printmissionlist.html 경로
});

app.use('/api/auth', authRoutes);

app.use('/dashboard', missionRoutes); // 誘몄뀡 �씪�슦�듃瑜� /dashboard濡� �꽕�젙
app.use('/api/rooms', roomRoutes);

app.use('/api/missions', missionRoutes); // 미션 관련 라우트 등록

app.use('/result', resultRoutes); // '/result' 경로에 라우트 연결

// 친구 리스트 라우트 추가
app.use('/dashboard/friends', friendRoutes);
app.use('/api/cVote', cVoteRoutes);
app.use('/api/comumunity_missions', c_missionRoutes);
cron.schedule('0 0 * * *', () => {
    console.log('미션 상태 확인 및 처리 시작');
    checkMissionStatus();
});



// 미션 마감기한 확인
// cron.schedule('* * * * *', () => { // 매일 자정 실행
cron.schedule('0 0 * * *', () => { // 매일 자정 실행
    console.log('마감 기한 확인 작업 시작');
    checkMissionDeadline();
});

// // ======== 수정 JWT ============
// // JWT 인증 미들웨어로 보호된 라우트
// app.use('/dashboard', require('./middleware/authMiddleware'), missionRoutes);
// app.use('/api/rooms', require('./middleware/authMiddleware'), roomRoutes);
// app.use('/api/cVote', require('./middleware/authMiddleware'), cVoteRoutes);

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});