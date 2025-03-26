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

router.delete('/deleteAccount', loginRequired, authController.deleteAccount); // 추가: 계정 탈퇴 경로


//================================Token===============================
const loginRequired = require('../middleware/loginRequired'); // 로그인 확인 미들웨어 불러오기 (로그인이 필요한 기능이 있을시 해당 라우터에 사용됨)

// 로그인 라우터
router.post('/loginToken', authController.loginToken);

// 로그아웃 라우터
router.post('/logoutToken', loginRequired, authController.logoutToken);



module.exports = router;
