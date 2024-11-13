// middleware/authMiddleware.js

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

module.exports = requireAuth;