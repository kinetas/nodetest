// ✅ Express API Gateway with auth failover (헬스체크 포함)
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const fetch = require('node-fetch');
require('dotenv').config();

const app = express();

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
      '^/auth': '/api/auth', // ✅ 핵심! auth 서버가 기대하는 경로로 바꿔줌
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

// ✅ /mission → nodetest
app.use('/', createProxyMiddleware({
  target: process.env.NODETEST_URL,
  changeOrigin: true,
}));

// ✅ Gateway 서버 시작
app.listen(3000, () => {
  console.log('🚪 API Gateway running on port 3000');
});
