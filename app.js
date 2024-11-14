const express = require('express');
const session = require('express-session'); //�꽭�뀡異붽��
const path = require('path');
const authRoutes = require('./routes/authRoutes'); // �씪�슦�듃 媛��졇�삤湲�
const missionRoutes = require('./routes/missionRoutes'); // 誘몄뀡 �씪�슦�듃 遺덈윭�삤湲�
const roomRoutes = require('./routes/roomRoutes');
const app = express();
const PORT = 3000;

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

// Static folder to serve the HTML file
app.use(express.static('public'));

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

app.use('/api/auth', authRoutes);

app.use('/dashboard', missionRoutes); // 誘몄뀡 �씪�슦�듃瑜� /dashboard濡� �꽕�젙
app.use('/api/rooms', roomRoutes);

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});