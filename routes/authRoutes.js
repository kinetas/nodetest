const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const findInfoController = require('../controllers/findInfoController');

router.post('/login', authController.login);

// // ===== JWT 기반 로그인 =====
// router.post('/login', authController.login);
// router.post('/register', authController.register);
// router.post('/findUid', findInfoController.findUid);
// router.post('/changePassword', findInfoController.changePassword);

router.post('/register', authController.register);
router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가
router.post('/changePassword', findInfoController.changePassword); // 비밀번호 변경 경로 추가
router.post('/logout', authController.logOut); // 로그아웃 경로 추가

router.delete('/deleteAccount', authController.deleteAccount); // 추가: 계정 탈퇴 경로

// // JWT 기반에서는 로그아웃 불필요, 클라이언트에서 토큰 제거
// router.post('/logout', authController.logOut);


module.exports = router;
