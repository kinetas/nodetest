const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friendController');
const requireAuth = require('../middleware/authMiddleware'); // 세션 인증 미들웨어
const fcmController = require('../controllers/fcmController'); 

// i_friend 리스트 출력
router.get('/ifriends', requireAuth, friendController.printIFriend);

// t_friend 리스트 출력
router.get('/tfriends', requireAuth, friendController.printTFriend);

// 친구 삭제
router.delete('/delete', requireAuth, friendController.friendDelete);

// 친구 요청 보내기
router.post('/request', requireAuth, friendController.friendRequestSend,fcmController.sendFriendRequestNotification);

// 친구 요청 수락
router.post('/accept', requireAuth, friendController.friendRequestAccept,fcmController.sendFriendRequestNotification);

// 친구 요청 거절
router.post('/reject', requireAuth, friendController.friendRequestReject,fcmController.sendFriendRequestNotification);

module.exports = router;