const express = require('express');
const session = require('express-session'); //�꽭��?�異붽��???
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

//==============================================================================
//======================MSA 적용 시 삭제========================================
// =========== Keycloak ===========
const { keycloak, memoryStore } = require('./keycloak');
//==============================================================================


const db = require('./config/db');
const { Room, Mission } = require('./models/relations'); // �??�?? ?��?�� 불러?���??

const app = express();
const PORT = 3002;
const roomController = require('./controllers/roomController');
//=====================추�??========================
// const SequelizeStore = require('connect-session-sequelize')(session.Store);

// // ======== ?��?�� JWT ============
const jwt = require('jsonwebtoken'); // JWT 추�??
const loginRequired = require('./middleware/loginRequired'); // JWT 미들웨어 추가
// const requireAuth = require('./middleware/authMiddleware');

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
app.use(session({
    secret: 'your_secret_key', // �꽭��?? �븫�샇�솕�뿉 �궗�슜�븷 �궎
    resave: false, // �꽭��?��?�� �빆�긽 ����?���븷吏� �뿬?���???
    saveUninitialized: false, // ?��?��린�?���릺吏� �븡���??? �꽭��?��?�� ����?���븷吏� �뿬?���???
    // store: new SequelizeStore({
    //     db: sequelize, // Sequelize ?��?��?��?��??? ?���??
    // }),
    // cookie: {
    //     maxAge: 24 * 60 * 60 * 1000, // 1?��
    //     httpOnly: true,
    //     secure: false, // HTTPS ?��?�� ?�� true�?? ?��?��
    // }
    store: memoryStore,
    cookie: { maxAge: 24 * 60 * 60 * 1000 } // ?��좏궎�쓽 ��??�슚 湲곌�??? (�뿬湲곗꽌�?�� �븯?���???)
}));

app.use(keycloak.middleware());

// 🔁 Authorization Code Flow 처리용 콜백
app.get('/callback', async (req, res) => {
    const code = req.query.code;
  
    if (!code) return res.status(400).send("코드가 없습니다.");
  
    try {
      // Keycloak 서버에 토큰 요청
      const tokenRes = await axios.post('http://27.113.11.48:8080/realms/master/protocol/openid-connect/token', new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        // redirect_uri: 'http://27.113.11.48:3000/callback',
        redirect_uri: 'myapp://login-callback',
        client_id: 'nodetest',
        client_secret: 'ptR4hZ66Q6dvBCWzdiySdk57L7Ow2OzE'  // → Keycloak 콘솔에서 확인 가능
      }), {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      });
  
      const { access_token } = tokenRes.data;
  
      // 토큰을 파라미터로 전달 (dashboard 페이지에서 처리)
      res.redirect(`/dashboard#access_token=${access_token}`);
    } catch (err) {
      console.error('[토큰 요청 오류]', err.response?.data || err);
      res.status(500).send("토큰 요청 실패");
    }
  });

// // ✅ 루트 경로에서 바로 로그인으로 유도
// app.get('/', keycloak.protect(), (req, res) => {
//     const token = req.kauth.grant.access_token.token;
//     res.redirect(`/dashboard#access_token=${token}`);
//     // res.redirect('/dashboard');
// });

//===========키클락 테스트 화면=============
// app.get('/keycloak-test', keycloak.protect(), (req, res) => {
//     res.send("Keycloak 인증 성공! 🎉");
// });

// // ======== ?��?�� JWT ============
// // JSON ?��?���??? URL ?��코딩 ?��?��
// app.use(cors());
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// Static folder to serve the HTML file
app.use(express.static('public'));


// 메시�??? ????��?�� 처리?��?�� API ?��?��?��?��?�� 추�??
// app.post('/api/messages', (req, res) => {
//     const { u1_id, u2_id, r_id, message_contents } = req.body;})
   /* // DB?�� 메시�??? ????�� 로직 추�??
    if (!u1_id || !u2_id || !r_id || !message_contents) {
        console.error('Missing required fields:', { u1_id, u2_id, r_id, message_contents});
        return res.status(400).json({ message: '?��?�� 값이 ?��?��?��?��?��?��?��.' });
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

            // DB?�� ?��공적?���??? ????��?�� 경우
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
app.post('/api/rooms/enter', roomController.enterRoom);


// �꽭��?? �씤利� 誘몃뱾�?���뼱
// const requireAuth = (req, res, next) => {
//     if (!req.session.user) {
//         return res.status(401).json({ message: '濡쒓?���씤�씠 �븘�슂��??�땲�떎.' });
//     }
//     next();
// };



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
//==============================================================================
//======================MSA 적용 시 삭제========================================
// app.get('/user-info', keycloak.protect(), (req, res) => {
//     const userInfo = req.kauth.grant.access_token.content;
//     const userId = userInfo.preferred_username || userInfo.sub;
//     res.json({ userId });
// });
//==============================================================================

app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
// // ✅ 대시보드 접근 시 Keycloak 인증 요구
// app.get('/', keycloak.protect(), (req, res) => {
//     const token = req.kauth.grant.access_token.token;
//     res.redirect(`/dashboard#access_token=${token}`);
// });
// app.get('/dashboard', (req, res) => {
//     res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
// });
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html'));
});
app.get('/rooms', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'rooms.html'));
});

app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  //?��?��?��/비�??번호 찾기 ?��?���???
});
app.get('/cVote', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'cVote.html'));
});

app.get('/chat', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'chat.html')); //채팅 ?��?���???
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

//==============================================================================
//======================MSA 적용 시 삭제========================================
// app.use((req, res, next) => {
//     if (req.kauth?.grant?.access_token?.content?.preferred_username) {
//       req.currentUserId = req.kauth.grant.access_token.content.preferred_username;
//     }
//     next();
// });
//==============================================================================

app.use('/chat', timeConverterMiddleware, loginRequired, chatRoutes); //JWT토큰
// app.use('/chat', timeConverterMiddleware, chatRoutes);

//==============================================================================
//======================MSA 적용 시 삭제========================================
app.use('/api/auth', timeConverterMiddleware, authRoutes);
// userInfoRoutes 
app.use('/api/user-info', timeConverterMiddleware, userInfoRoutes);
//==============================================================================

app.use('/dashboard', timeConverterMiddleware, loginRequired, missionRoutes);  //JWT토큰
// app.use('/dashboard', keycloak.protect(), timeConverterMiddleware, missionRoutes);

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