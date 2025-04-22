const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const findInfoController = require('../controllers/findInfoController');

const loginRequired = require('../middleware/loginRequired'); // 로그인 확인 미들웨어 불러오기 (로그인이 필요한 기능이 있을시 해당 라우터에 사용됨)

const { keycloak } = require('../keycloak');

// router.post('/login', authController.login);

router.post('/register', authController.register);
router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가
// router.post('/changePassword', findInfoController.changePassword); // 비밀번호 변경 경로 추가
router.post('/logout', authController.logOut); // 로그아웃 경로 추가

// router.delete('/deleteAccount', authController.deleteAccount); // 추가: 계정 탈퇴 경로

// // JWT 기반에서는 로그아웃 불필요, 클라이언트에서 토큰 제거
// router.post('/logout', authController.logOut);

//================================Token===============================

// 로그인 라우터
router.post('/loginToken', authController.loginToken);

// 로그아웃 라우터
// 쿠키에서 토큰을 제거하는 작업은 동기적인 작업이므로, async 처리 불필요
// router.post('/logoutToken', loginRequired, authController.logoutToken);
router.post('/logoutToken', authController.logoutToken);

// 계정탈퇴 
// router.delete('/deleteAccountToken', loginRequired, authController.deleteAccount);
// router.delete('/deleteAccountToken', authController.deleteAccount);

// 비밀번호 변경
router.post('/changePassword', findInfoController.changePassword);

// ===================== KeyCloak ==========================
router.get('/keycloak-login-url', authController.getKeycloakLoginUrl);

router.post('/keycloak-direct-login', authController.keycloakDirectLogin);

router.get('/registerKeyCloak', keycloak.protect(), authController.getOrCreateUserFromKeycloak);
router.delete('/deleteAccountToken', keycloak.protect(), authController.deleteAccountFromKeycloak);

// ✅ Keycloak access_token → 우리 서버 JWT 발급
router.post('/issueJwtFromKeycloak', authController.issueJwtFromKeycloak);

module.exports = router;
