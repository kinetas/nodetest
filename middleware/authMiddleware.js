// middleware/authMiddleware.js

// 쿠키
const requireAuth = (req, res, next) => {
    // 세션에 사용자 정보가 있는지 확인
    if (req.session && req.session.user) {
        // 인증된 사용자인 경우 다음 미들웨어 또는 라우트로 이동
        return next();
    } else {
        // 인증되지 않은 경우 401 응답
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
};

// // ======== 수정 JWT ============
// const jwt = require('jsonwebtoken');

// const requireAuth = (req, res, next) => {
//     const token = req.headers.authorization?.split(' ')[1]; // "Bearer [TOKEN]"

//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         req.user = decoded; // 요청 객체에 사용자 정보 추가
//         next();
//     } catch (error) {
//         return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//     }
// };

module.exports = requireAuth;