const express = require('express');
const router = express.Router();
const authController = require('../controller/authController');
const findInfoController = require('../controller/findInfoController');
const userInfoController = require('../controller/userInfoController');

const { keycloak } = require('../keycloak');

router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가

router.post('/logoutToken', authController.logoutToken);

// 비밀번호 변경
router.post('/changePassword', findInfoController.changePassword);

// ===================== KeyCloak ==========================
router.get('/keycloak-login-url', authController.getKeycloakLoginUrl);

router.post('/keycloak-direct-login', authController.keycloakDirectLogin);

router.get('/registerKeyCloak', keycloak.protect(), authController.getOrCreateUserFromKeycloak);
router.delete('/deleteAccountToken', keycloak.protect(), authController.deleteAccountFromKeycloak);

// ✅ Keycloak access_token → 우리 서버 JWT 발급
router.get('/issueJwtFromKeycloak', keycloak.protect(), authController.issueJwtFromKeycloak);

// =========== userInfo ===============
// ✅ Keycloak 인증 필요 라우트 설정
router.get('/user-id', keycloak.protect(), userInfoController.getLoggedInUserId);
router.get('/user-nickname', keycloak.protect(), userInfoController.getLoggedInUserNickname);
router.get('/user-all', keycloak.protect(), userInfoController.getLoggedInUserAll);

module.exports = router;
