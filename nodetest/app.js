const express = require('express');
// const session = require('express-session'); //�꽭��?�異붽��???
const cron = require('node-cron');
const path = require('path');
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes'); // 誘몄??? �씪�슦�듃 ?��?��?���삤湲�
const roomRoutes = require('./routes/roomRoutes');
const friendRoutes = require('./routes/friendRoutes');
const cVoteRoutes = require('./routes/cVoteRoutes');
const c_missionRoutes = require('./routes/c_missionRoutes');
const resultRoutes = require('./routes/resultRoutes'); // 결과 ?��?��?�� 추�??
//==============================================================================
//======================MSA 적용 시 삭제========================================
const authRoutes = require('./routes/authRoutes'); // �씪�슦�듃 媛��졇�삤湲�
const userInfoRoutes = require('./routes/userInfoRoutes');
//==============================================================================
const recommendationMissionRoutes = require('./routes/recommendationMissionRoutes'); // 라우트 파일 가져오기
const aiRoutes = require('./routes/aiRoutes');
const { checkMissionStatus } = require('./controllers/c_missionController');
const { checkMissionDeadline } = require('./controllers/missionController');
const { checkAndUpdateMissions } = require('./controllers/cVoteController');
require('dotenv').config();

const timeConverterMiddleware = require('./middleware/timeConverterMiddleware');
const axios = require('axios');

const db = require('./config/db');
const { Room, Mission } = require('./models/relations'); // �??�?? ?��?�� 불러?���??

const app = express();
const PORT = 3000;
const roomController = require('./controllers/roomController');
//=====================추�??========================
// const SequelizeStore = require('connect-session-sequelize')(session.Store);

// // ======== ?��?�� JWT ============
const jwt = require('jsonwebtoken'); // JWT 추�??
const loginRequired = require('./middleware/loginRequired'); // JWT 미들웨어 추가

const cors = require('cors');
app.use(cors());  // 모든 출처?�� ?���????�� ?��?��
app.use(cors({
    origin: 'http://27.113.11.48:3000',
    allowedHeaders: ['Authorization', 'Content-Type'],
    // credentials: true // 쿠키 방식 사용 시 필요, 지금은 무관
  }));

app.use(express.json()); // JSON �뙆�떛�쓣 �쐞�븳 誘몃뱾�?���뼱 �꽕�젙
app.use(express.urlencoded({ extended: true })); // URL �씤?��붾뵫�맂 �뜲�씠�꽣 �뙆�떛�쓣 �쐞�븳 誘몃뱾�?���뼱 �꽕�젙

// �꽭��?? �꽕�젙
// app.use(session({
//     secret: 'your_secret_key', // �꽭��?? �븫�샇�솕�뿉 �궗�슜�븷 �궎
//     resave: false, // �꽭��?��?�� �빆�긽 ����?���븷吏� �뿬?���???
//     saveUninitialized: false, // ?��?��린�?���릺吏� �븡���??? �꽭��?��?�� ����?���븷吏� �뿬?���???
//     // store: new SequelizeStore({
//     //     db: sequelize, // Sequelize ?��?��?��?��??? ?���??
//     // }),
//     // cookie: {
//     //     maxAge: 24 * 60 * 60 * 1000, // 1?��
//     //     httpOnly: true,
//     //     secure: false, // HTTPS ?��?�� ?�� true�?? ?��?��
//     // }
//     store: memoryStore,
//     cookie: { maxAge: 24 * 60 * 60 * 1000 } // ?��좏궎�쓽 ��??�슚 湲곌�??? (�뿬湲곗꽌�?�� �븯?���???)
// }));

// // 🔁 Authorization Code Flow 처리용 콜백
// app.get('/callback', async (req, res) => {
//     const code = req.query.code;
  
//     if (!code) return res.status(400).send("코드가 없습니다.");
  
//     try {
//       // Keycloak 서버에 토큰 요청
//       const tokenRes = await axios.post('http://27.113.11.48:8080/realms/master/protocol/openid-connect/token', new URLSearchParams({
//         grant_type: 'authorization_code',
//         code: code,
//         // redirect_uri: 'http://27.113.11.48:3000/callback',
//         redirect_uri: 'myapp://login-callback',
//         client_id: 'nodetest',
//         client_secret: 'ptR4hZ66Q6dvBCWzdiySdk57L7Ow2OzE'  // → Keycloak 콘솔에서 확인 가능
//       }), {
//         headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
//       });
  
//       const { access_token } = tokenRes.data;
  
//       // 토큰을 파라미터로 전달 (dashboard 페이지에서 처리)
//       res.redirect(`/dashboard#access_token=${access_token}`);
//     } catch (err) {
//       console.error('[토큰 요청 오류]', err.response?.data || err);
//       res.status(500).send("토큰 요청 실패");
//     }
//   });

// Static folder to serve the HTML file
app.use(express.static('public'));

app.post('/api/rooms/enter', roomController.enterRoom);

// �삁�떆: ����?��蹂�??�??? �씪�슦�듃 蹂댄?��
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
    // const userId = req.session.user.id;
    // res.json({ userId });
});
app.get('/community_missions', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'community_missions.html')); // community-missions.html ?��?���??? 경로
});

// ��??���??? �젙蹂�??�� 諛섑?���븯�뒗 �씪�슦�듃 ?��붽��???
app.get('/user-info', loginRequired, (req, res) => {
    // res.json({ userId: req.session.user.id }); //세션기반
    res.json({ userId: req.currentUserId });    //토큰기반
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

app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  // ID찾기, PW변경
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

app.use('/chat', timeConverterMiddleware, loginRequired, chatRoutes); //JWT토큰
// app.use('/chat', timeConverterMiddleware, chatRoutes);

//==============================================================================
//======================MSA 적용 시 삭제========================================
app.use('/api/auth', timeConverterMiddleware, authRoutes);

app.use('/api/user-info', timeConverterMiddleware, userInfoRoutes);
//==============================================================================

app.use('/dashboard', timeConverterMiddleware, missionRoutes);  //JWT토큰

app.use('/api/rooms', timeConverterMiddleware, loginRequired, roomRoutes); //JWT토큰
// app.use('/api/rooms', timeConverterMiddleware, roomRoutes);

app.use('/api/missions', timeConverterMiddleware, loginRequired, missionRoutes); //JWT토큰
// app.use('/api/missions', timeConverterMiddleware, missionRoutes);

app.use('/result', timeConverterMiddleware, loginRequired, resultRoutes); // '/result' 경로 //JWT토큰
// app.use('/result', timeConverterMiddleware, resultRoutes); // '/result' 경로

app.use('/dashboard/friends', timeConverterMiddleware, loginRequired, friendRoutes); //JWT토큰
// app.use('/dashboard/friends', timeConverterMiddleware, friendRoutes);

app.use('/api/cVote', timeConverterMiddleware, loginRequired, cVoteRoutes); //JWT토큰
// app.use('/api/cVote', timeConverterMiddleware, cVoteRoutes);

app.use('/api/comumunity_missions', timeConverterMiddleware, loginRequired, c_missionRoutes); //JWT토큰
// app.use('/api/comumunity_missions', timeConverterMiddleware, c_missionRoutes);

// //AI관련
app.use('/api/ai', aiRoutes);

// cron.schedule('* * * * *', () => { // �?? �?? ?��?�� 
cron.schedule('0 0 * * *', () => {
    console.log('미션 ?��?�� ?��?�� �??? 처리 ?��?��');
    checkMissionStatus();
});


// 추천 미션 라우트 설정
app.use('/api/recommendationMission', recommendationMissionRoutes);

// // 미션 마감기한 ?��?�� (�?? 분마?�� ?��?��)
// cron.schedule('* * * * *', () => { // �?? �?? ?��?��

// 미션 마감기한 ?��?�� (매일 마다 ?��?��)
 cron.schedule('0 0 * * *', () => { // 매일 ?��?��
    console.log('마감 기한 ?��?�� �?? ?��?�� ?��?��?��?�� ?��?��');
    checkMissionDeadline();
});
cron.schedule('0 0 * * *', async () => {
    console.log('���� ���� ���� �۾� ����');
    await checkAndUpdateMissions();
});

//const { sendNotificationController } = require('./controllers/sendNotificationController');
const {sendNotificationController} = require('./controllers/notificationController');

// FCM ?���?? ?��?�� API ?��?��?��?��?��
app.post('/api/send-notification', sendNotificationController);

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

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});