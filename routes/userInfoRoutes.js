// routes/userInfoRoutes.js
const express = require('express');
const router = express.Router();
const userInfoController = require('../controllers/userInfoController');

// 로그인한 사용자의 u_id 반환
router.get('/user-id', userInfoController.getLoggedInUserId);

// 로그인한 사용자의 u_nickname 반환
router.get('/user-nickname', userInfoController.getLoggedInUserNickname);

// 로그인한 사용자의 모든 정보 반환
router.get('/user-all', userInfoController.getLoggedInUserAll);

module.exports = router;