const express = require('express');
const session = require('express-session');
const app = express();
const PORT = 3004;
const { keycloak, memoryStore } = require('./keycloak');

require('dotenv').config();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: false,
    store: memoryStore,
    cookie: { maxAge: 24 * 60 * 60 * 1000 }
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

app.get('/user-info', keycloak.protect(), (req, res) => {
    const userInfo = req.kauth.grant.access_token.content;
    const userId = userInfo.preferred_username || userInfo.sub;
    res.json({ userId });
});

app.use('/api/auth', require('./routes/authRoutes'));

app.listen(3004, () => {
    console.log('Auth server listening on port 3004');
});