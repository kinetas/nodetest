const express = require('express');
// const session = require('express-session'); //세션추가
const path = require('path');
const authRoutes = require('./routes/authRoutes'); // 라우트 가져오기
const app = express();
const PORT = 3000;

// //cors
// const cors = require('cors');
// app.use(cors({ origin: '*' }));

app.use(express.json()); // JSON 파싱을 위한 미들웨어 설정
app.use(express.urlencoded({ extended: true })); // URL 인코딩된 데이터 파싱을 위한 미들웨어 설정

// // 세션 설정
// app.use(session({
//     secret: 'your_secret_key', // 세션 암호화에 사용할 키
//     resave: false, // 세션을 항상 저장할지 여부
//     saveUninitialized: false, // 초기화되지 않은 세션을 저장할지 여부
//     cookie: { maxAge: 1000 * 60 * 60 * 24 } // 쿠키의 유효 기간 (여기서는 하루)
// }));

// Static folder to serve the HTML file
app.use(express.static('public'));

// 짹창쨘쨩 HTML 횈횆��횕 횁짝째첩
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html')); // 대시보드 HTML 파일
});
app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html')); // 회원가입 HTML 파일
});

app.use('/api/auth', authRoutes);

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});