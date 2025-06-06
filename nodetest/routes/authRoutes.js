const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const findInfoController = require('../controllers/findInfoController');
const loginRequired = require('../middleware/loginRequired'); // 로그인 확인 미들웨어 불러오기 (로그인이 필요한 기능이 있을시 해당 라우터에 사용됨)

//======================authController=====================
// ===================== KeyCloak ==========================
router.post('/register-keycloak-direct', authController.registerKeycloakDirect); // 회원가입 (register 화면에서 회원가입)
router.post('/keycloak-direct-login', authController.keycloakDirectLogin); // KeyCloak 직접 로그인 (index 화면에서 로그인)
router.post('/logoutToken', loginRequired, authController.logoutToken); // 로그아웃 라우터
router.delete('/deleteAccountToken', loginRequired, authController.deleteAccountFromKeycloak); // 계졍탈퇴

//======================findInfoController=====================
router.post('/changePassword', findInfoController.changePassword); // 비밀번호 변경
router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가

module.exports = router;
