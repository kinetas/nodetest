// ✅ Express API Gateway with auth failover (헬스체크 포함)
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const fetch = require('node-fetch');
const path = require('path');
const http = require('http');
const fs = require('fs');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();

const fs = require('fs');

// ✅ 정적 파일 서빙 디렉토리 설정
const publicDir = path.join(__dirname, 'public');
const profileImageDir = path.join(publicDir, 'profile_images');
const voteImageDir = path.join(publicDir, 'vote_images');
const missionImageDir = path.join(publicDir, 'mission_images');
const communityImageDir = path.join(publicDir, 'community_images');
const chatMessageImageDir = path.join(publicDir, 'chat_message_images');

[profileImageDir, voteImageDir, missionImageDir, communityImageDir, chatMessageImageDir].forEach(dir => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

// ✅ 정적 서빙
app.use(express.static(publicDir));
app.use('/profile_images', express.static(profileImageDir));
app.use('/vote_images', express.static(voteImageDir));
app.use('/mission_images', express.static(missionImageDir));
app.use('/community_images', express.static(communityImageDir));
app.use('/chat_message_images', express.static(chatMessageImageDir));


// ==================== 라우팅: HTML 정적 페이지 ====================
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});
app.get('/community_missions', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'community_missions.html'));
});
app.get('/community_comments/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'community_comments.html'));
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
app.get('/league', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'league.html'));
});

// ✅ 프로필 이미지 업로드 엔드포인트
const upload = multer({
  storage: multer.diskStorage({
    destination: (_, __, cb) => cb(null, profileImageDir),
    filename: (_, file, cb) => cb(null, uuidv4() + path.extname(file.originalname))
  })
});

app.post('/api/upload-profile-image', upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ message: '이미지 파일이 없습니다.' });
  const imageUrl = `/profile_images/${req.file.filename}`;
  res.json({ imageUrl });
});


const authTargets = [
  process.env.AUTH_SERVER1_URL,
  process.env.AUTH_SERVER2_URL
];
let currentAuth = 0;

// ✅ 비동기 헬스체크 함수
async function getHealthyTarget() {
  for (let i = 0; i < authTargets.length; i++) {
    const index = (currentAuth + i) % authTargets.length;
    const url = authTargets[index];
    try {
      const res = await fetch(url + '/healthz', { timeout: 1000 });
      if (res.ok) {
        currentAuth = (index + 1) % authTargets.length;
        return url;
      }
    } catch (_) {}
  }
  return null; // 전부 죽었을 경우
}

// ✅ /auth 프록시 with 헬스체크 + pathRewrite
app.use('/auth', async (req, res, next) => {
  const target = await getHealthyTarget();
  if (!target) return res.status(503).send('모든 auth 서버가 다운됨');
  createProxyMiddleware({
    target,
    changeOrigin: true,
    pathRewrite: {
      '^/auth': '', // ✅ 핵심! auth 서버가 기대하는 경로로 바꿔줌
    }
  })(req, res, next);
});


// ✅ /ai → rag_server
app.use('/ai', createProxyMiddleware({
  target: process.env.RAG_SERVER_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/ai': '', // ✅ 이거 꼭 있어야 함
  }
}));

// ✅ /intent → intent_server
app.use('/intent', createProxyMiddleware({
  target: process.env.INTENT_SERVER_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/intent': '',  // ✅ '/intent' 잘라내서 FastAPI에 보냄
  },
}));


app.use('/nodetest', (req, res, next) => {
  console.log('[GATEWAY]', req.method, req.originalUrl, req.headers.authorization);
  next();
});
// ✅ /mission → nodetest
app.use('/nodetest', createProxyMiddleware({
  target: process.env.NODETEST_URL,
  changeOrigin: true,
  pathRewrite: { '^/nodetest': '' },
}));

app.get('/health', (req, res) => {
  res.status(200).send('Healthy');
});

// app.use('/socket.io', createProxyMiddleware({
//   target: process.env.CHAT_SERVER_URL, // 예: 'http://chat_server:3001'
//   changeOrigin: true,
//   ws: true // ⭐ WebSocket 연결 허용
// }));

const server = http.createServer(app);

server.on('upgrade', (req, socket, head) => {
  console.log('[GATEWAY] WebSocket upgrade 요청 수신');
  app.emit('upgrade', req, socket, head);
});
// ✅ Gateway 서버 시작
server.listen(3000, '0.0.0.0', () => {
  console.log('🚪 API Gateway running on port 3000');
});
