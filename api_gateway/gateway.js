const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// 프록시 설정: /auth → auth_server
app.use('/auth', createProxyMiddleware({
  target: 'http://auth_server:3000',
  changeOrigin: true,
}));

// /mission → mission_server
app.use('/mission', createProxyMiddleware({
  target: 'http://nodetest:3000',
  changeOrigin: true,
}));

// /ai → rag_server
app.use('/ai', createProxyMiddleware({
  target: 'http://rag_server:8000',
  changeOrigin: true,
}));

// /intent → intent_server
app.use('/intent', createProxyMiddleware({
  target: 'http://intent_server:8002',
  changeOrigin: true,
}));

app.listen(3000, () => {
    console.log('API Gateway running on port 3000');
  });