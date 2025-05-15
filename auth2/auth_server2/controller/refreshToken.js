const jwt = require('jsonwebtoken'); // jwt 모듈 불러오기
const { refreshToken } = require('../utils/jwt');

// JWT 토큰을 새로 고치는 미들웨어 함수
const refreshJwtMiddleware = (req, res, next) => {
  // 요청으로부터 쿠키의 토큰 정보 가져오기
  const token = req.cookies.token;

  // 토큰이 존재하는 경우
  if (token) {
    // 토큰을 새로고침하고 새 토큰을 가져옴
    const newToken = refreshToken(token);

    // 새 토큰이 있다면 쿠키에 저장
    if (newToken) {
      res.cookie('token', newToken, { httpOnly: true, maxAge: 3600000 });
    }
  }

  // 다음 미들웨어로 이동
  next();
};

// 미들웨어 함수 내보내기
module.exports = refreshJwtMiddleware;