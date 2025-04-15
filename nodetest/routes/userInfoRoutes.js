// routes/userInfoRoutes.js
const express = require('express');
const router = express.Router();
const userInfoController = require('../controllers/userInfoController');
const { keycloak } = require('../keycloak'); // ✅ Keycloak 미들웨어 가져오기

// // 로그인한 사용자의 u_id 반환
// router.get('/user-id', userInfoController.getLoggedInUserId);
// // 로그인한 사용자의 u_nickname 반환
// router.get('/user-nickname', userInfoController.getLoggedInUserNickname);
// // 로그인한 사용자의 모든 정보 반환
// router.get('/user-all', userInfoController.getLoggedInUserAll);

// ✅ Keycloak 인증 필요 라우트 설정
router.get('/user-id', keycloak.protect(), userInfoController.getLoggedInUserId);
router.get('/user-nickname', keycloak.protect(), userInfoController.getLoggedInUserNickname);
router.get('/user-all', keycloak.protect(), userInfoController.getLoggedInUserAll);

module.exports = router;