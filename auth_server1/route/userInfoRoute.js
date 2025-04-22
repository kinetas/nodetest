// routes/userInfoRoutes.js
const express = require('express');
const router = express.Router();
const userInfoController = require('../controllers/userInfoController');
const { keycloak } = require('../keycloak'); // ✅ Keycloak 미들웨어 가져오기

// ✅ Keycloak 인증 필요 라우트 설정
router.get('/user-id', keycloak.protect(), userInfoController.getLoggedInUserId);
router.get('/user-nickname', keycloak.protect(), userInfoController.getLoggedInUserNickname);
router.get('/user-all', keycloak.protect(), userInfoController.getLoggedInUserAll);

module.exports = router;