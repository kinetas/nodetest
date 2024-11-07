const express = require('express');
const path = require('path');
const authRoutes = require('./routes/authRoutes'); // 라우트 가져오기
const app = express();
const PORT = 3000;
app.use(express.json()); // JSON 파싱을 위한 미들웨어 설정
app.use(express.urlencoded({ extended: true })); // URL 인코딩된 데이터 파싱을 위한 미들웨어 설정

// Static folder to serve the HTML file
app.use(express.static('public'));

app.use((req, res, next) => {
    res.setHeader('Content-Type', 'text/html; charset=UTF-8');
    next();
});

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

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
