const jwt = require('jsonwebtoken'); // jwt 모듈 불러오기
const secretKey = process.env.JWT_SECRET_KEY;

const generateToken = (payload) => {
  const token = jwt.sign(payload, secretKey, { expiresIn: '1h' });
  console.log("🎯 토큰에 넣을 payload:", payload); // ✅ 로그 추가
  return token;
}; // jwt.sign() 메서드를 통해 jwt 토큰 발행. expiresIn : '1h' 설정으로 1시간 후 토큰이 만료되게 설정.

// 기존 토큰을 사용하여 새로운 토큰을 생성하는 함수
const refreshToken = (token) => {
  try {
    // 기존 토큰의 유효성 검사 및 디코딩
    const decoded = jwt.verify(token, secretKey);
    
    // 새로운 페이로드 생성
    const payload = {
      userId: decoded.userId,
    };
    
    // 새로운 토큰 생성
    const newToken = generateToken(payload);
    return newToken;
  } catch (error) {
    // 토큰 새로 고침 중 오류 발생 시 출력
    console.error('Error refreshing token:', error);
    return null;
  }
};

module.exports = { generateToken, refreshToken };