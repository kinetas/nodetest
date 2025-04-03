const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const findInfoController = require('../controllers/findInfoController');

// router.post('/login', authController.login);

router.post('/register', authController.register);
router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가
// router.post('/changePassword', findInfoController.changePassword); // 비밀번호 변경 경로 추가
router.post('/logout', authController.logOut); // 로그아웃 경로 추가

router.delete('/deleteAccount', authController.deleteAccount); // 추가: 계정 탈퇴 경로

// // JWT 기반에서는 로그아웃 불필요, 클라이언트에서 토큰 제거
// router.post('/logout', authController.logOut);

//================================Token===============================
const loginRequired = require('../middleware/loginRequired'); // 로그인 확인 미들웨어 불러오기 (로그인이 필요한 기능이 있을시 해당 라우터에 사용됨)

// 로그인 라우터
router.post('/loginToken', authController.loginToken);

// 로그아웃 라우터
// 쿠키에서 토큰을 제거하는 작업은 동기적인 작업이므로, async 처리 불필요
router.post('/logoutToken', (req, res) => {
    try {
        authController.logoutToken(req, res);
    } catch (err) {
        console.log(err);
        res.status(400).json({ message: err.message }); // JSON 형식으로 에러 메시지 반환
    }
});

// ✅ 비밀번호 변경 라우터는 JWT 인증 필요
router.post('/changePassword', loginRequired, findInfoController.changePassword);



module.exports = router;
