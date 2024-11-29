// middleware/authMiddleware.js

// // 쿠키
// const requireAuth = (req, res, next) => {
//     // 세션에 사용자 정보가 있는지 확인
//     if (req.session && req.session.user) {
//         // 인증된 사용자인 경우 다음 미들웨어 또는 라우트로 이동
//         return next();
//     } else {
//         // 인증되지 않은 경우 401 응답
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }
// };

//=================추가===============================
const User = require('../models/userModel'); // User 모델 가져오기
const requireAuth = async (req, res, next) => {
    if (!req.session || !req.session.user) {
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }

    try {
        const user = await User.findOne({ where: { u_id: req.session.user.id } });

        if (!user || user.session_id !== req.session.id) {
            req.session.destroy();
            return res.status(401).json({ message: '다른 기기에서 로그인되었습니다. 다시 로그인해주세요.' });
        }

        next();
    } catch (error) {
        console.error('세션 유효성 확인 중 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
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