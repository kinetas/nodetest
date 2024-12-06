const express = require('express');
const session = require('express-session'); //�꽭��?�異붽��???
const cron = require('node-cron');
const path = require('path');
const chatRoutes = require('./routes/chatRoutes');
const authRoutes = require('./routes/authRoutes'); // �씪�슦�듃 媛��졇�삤湲�
const missionRoutes = require('./routes/missionRoutes'); // 誘몄??? �씪�슦�듃 ?��?��?���삤湲�
const roomRoutes = require('./routes/roomRoutes');
const friendRoutes = require('./routes/friendRoutes');
const cVoteRoutes = require('./routes/cVoteRoutes');
const c_missionRoutes = require('./routes/c_missionRoutes');
const resultRoutes = require('./routes/resultRoutes'); // 결과 ?��?��?�� 추�??
const userInfoRoutes = require('./routes/userInfoRoutes');
const { checkMissionStatus } = require('./controllers/c_missionController');
const { checkMissionDeadline } = require('./controllers/missionController');
const { checkAndUpdateMissions } = require('./controllers/cVoteController');


const db = require('./config/db');
const { Room, Mission } = require('./models/relations'); // �??�?? ?��?�� 불러?���??

const app = express();
const PORT = 3000;
const roomController = require('./controllers/roomController');
//=====================추�??========================
// const SequelizeStore = require('connect-session-sequelize')(session.Store);

// // ======== ?��?�� JWT ============
const jwt = require('jsonwebtoken'); // JWT 추�??
// const requireAuth = require('./middleware/authMiddleware');

const cors = require('cors');
app.use(cors());  // 모든 출처?�� ?���????�� ?��?��

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
    cookie: { maxAge: 24 * 60 * 60 * 1000 } // ?��좏궎�쓽 ��??�슚 湲곌�??? (�뿬湲곗꽌�?�� �븯?���???)
}));

// // ======== ?��?�� JWT ============
// // JSON ?��?���??? URL ?��코딩 ?��?��
// app.use(cors());
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// Static folder to serve the HTML file
app.use(express.static('public'));


// 메시�??? ????��?�� 처리?��?�� API ?��?��?��?��?�� 추�??
app.post('/api/messages', (req, res) => {
    const { u1_id, u2_id, r_id, message_contents } = req.body;})
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
const requireAuth = (req, res, next) => {
    if (!req.session.user) {
        return res.status(401).json({ message: '濡쒓?���씤�씠 �븘�슂��??�땲�떎.' });
    }
    next();
};



// �삁�떆: ����?��蹂�??�??? �씪�슦�듃 蹂댄?��
app.get('/dashboard', requireAuth, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
    // const userId = req.session.user.id;
    // res.json({ userId });
});
app.get('/community_missions', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'community_missions.html')); // community-missions.html ?��?���??? 경로
});

// ��??���??? �젙蹂�??�� 諛섑?���븯�뒗 �씪�슦�듃 ?��붽��???
app.get('/user-info', requireAuth, (req, res) => {
    res.json({ userId: req.session.user.id });
});



// 吏�??갹夷?��Ł HTML �쉱�쉮?��?��?���슃 �쉧吏앹?��泥�
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html')); // ����?��蹂�??�??? HTML �뙆�씪
});
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html')); // �쉶�썝媛��엯 HTML �뙆�씪
});
app.get('/rooms', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'rooms.html'));
});

app.get('/findinfo', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'findinfo.html'));  //?��?��?��/비�??번호 찾기 ?��?���???
});
app.get('/cVote', requireAuth, (req, res) => {
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

app.use('/chat', chatRoutes);

app.use('/api/auth', authRoutes);

app.use('/dashboard', missionRoutes); // 誘몄??? �씪�슦�듃?���??? /dashboard濡� �꽕�젙
app.use('/api/rooms', roomRoutes);

app.use('/api/missions', missionRoutes); // 미션 �????�� ?��?��?�� ?���???

app.use('/result', resultRoutes); // '/result' 경로?�� ?��?��?�� ?���???

// userInfoRoutes ?���??
app.use('/api/user-info', userInfoRoutes);

// 친구 리스?�� ?��?��?�� 추�??
app.use('/dashboard/friends', friendRoutes);
app.use('/api/cVote', cVoteRoutes);
app.use('/api/comumunity_missions', c_missionRoutes);
// cron.schedule('* * * * *', () => { // �?? �?? ?��?�� 
cron.schedule('0 0 * * *', () => {
    console.log('미션 ?��?�� ?��?�� �??? 처리 ?��?��');
    checkMissionStatus();
});


/*
// 미션 마감기한 ?��?�� (�?? 분마?�� ?��?��)
cron.schedule('* * * * *', () => { // �?? �?? ?��?��
*/
// // 미션 마감기한 ?��?�� (매일 마다 ?��?��)
 cron.schedule('0 0 * * *', () => { // 매일 ?��?��
    console.log('마감 기한 ?��?�� �?? ?��?�� ?��?��?��?�� ?��?��');
    checkMissionDeadline();
});
cron.schedule('0 0 * * *', async () => {
    console.log('���� ���� ���� �۾� ����');
    await checkAndUpdateMissions();
});
// // ======== ?��?�� JWT ============
// // JWT ?���??? 미들?��?���??? 보호?�� ?��?��?��
// app.use('/dashboard', require('./middleware/authMiddleware'), missionRoutes);
// app.use('/api/rooms', require('./middleware/authMiddleware'), roomRoutes);
// app.use('/api/cVote', require('./middleware/authMiddleware'), cVoteRoutes);

const { sendNotificationController } = require('./controllers/notificationController');


// FCM ?���?? ?��?�� API ?��?��?��?��?��
app.post('/api/send-notification', sendNotificationController);


app.use((req, res) => {
    res.status(404).send('404 Not Found');
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});


