const express = require('express');
const app = express();
const PORT = 3004;

require('dotenv').config();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const timeConverterMiddleware = require('./middleware/timeConverterMiddleware');
const loginRequired = require('./middleware/loginRequired'); // JWT 미들웨어 추가

app.get('/user-info', loginRequired, (req, res) => {
  res.json({ userId: req.currentUserId });    //토큰기반
});

app.use('/api/auth', timeConverterMiddleware, authRoutes);

app.use('/api/user-info', timeConverterMiddleware, userInfoRoutes);

app.listen(PORT, () => {
    console.log('Auth server listening on port 3004');
});