// ✅ Express API Gateway with auth failover (헬스체크 포함)
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const fetch = require('node-fetch');

const app = express();

const authTargets = ['http://auth_server_1:3000', 'http://auth_server_2:3000'];
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

// ✅ /auth 프록시 with 헬스체크
app.use('/auth', async (req, res, next) => {
  const target = await getHealthyTarget();
  if (!target) return res.status(503).send('모든 auth 서버가 다운됨');
  createProxyMiddleware({ target, changeOrigin: true })(req, res, next);
});


// ✅ /ai → rag_server
app.use('/ai', createProxyMiddleware({
  target: 'http://rag_server:8000',
  changeOrigin: true,
}));

// ✅ /intent → intent_server
app.use('/intent', createProxyMiddleware({
  target: 'http://intent_server:8002',
  changeOrigin: true,
}));

// ✅ /mission → nodetest
app.use('/', createProxyMiddleware({
  target: 'http://nodetest:3000',
  changeOrigin: true,
}));

// ✅ Gateway 서버 시작
app.listen(3000, () => {
  console.log('🚪 API Gateway running on port 3000');
});
