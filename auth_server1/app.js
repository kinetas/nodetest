const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3004;

require('dotenv').config();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const timeConverterMiddleware = require('./middleware/timeConverterMiddleware');
const authRoutes = require('./routes/authRoutes');

app.use('/api/auth', timeConverterMiddleware, authRoutes);

// 헬스체크 라우트 추가 (Gateway에서 사용함)
app.get('/healthz', (req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, () => {
    console.log('Auth server listening on port 3004');
});