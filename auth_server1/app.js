const express = require('express');
const app = express();
const PORT = 3004;

require('dotenv').config();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const loginRequired = require('./middleware/loginRequired'); // JWT 미들웨어 추가

app.get('/user-info', loginRequired, (req, res) => {
    const userInfo = req.kauth.grant.access_token.content;
    const userId = userInfo.preferred_username || userInfo.sub;
    res.json({ userId });
});

app.use('/api/auth', require('./routes/authRoutes'));

app.listen(3004, () => {
    console.log('Auth server listening on port 3004');
});