const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friendController');
const requireAuth = require('../middlewares/authMiddleware'); // 세션 인증 미들웨어

// i_friend 리스트 출력
router.get('/ifriends', requireAuth, friendController.printIFriend);

// t_friend 리스트 출력
router.get('/tfriends', requireAuth, friendController.printTFriend);

module.exports = router;