const express = require('express');
const router = express.Router();
const friendController = require('../controller/friendController');
const loginRequired = require('../middleware/loginRequired');   // JWT 인증 미들웨어
// const fcmController = require('../controllers/fcmController'); 

//==============================Token======================================
// i_friend 리스트 출력
router.get('/ifriends', loginRequired, friendController.printIFriend);

// t_friend 리스트 출력
router.get('/tfriends', loginRequired, friendController.printTFriend);

// 친구 삭제
router.delete('/delete', loginRequired, friendController.friendDelete);

// // 친구 요청 보내기
// router.post('/request', loginRequired, friendController.friendRequestSend,fcmController.sendFriendRequestNotification);

// // 친구 요청 수락
// router.post('/accept', loginRequired, friendController.friendRequestAccept,fcmController.sendFriendRequestNotification);

// // 친구 요청 거절
// router.post('/reject', loginRequired, friendController.friendRequestReject,fcmController.sendFriendRequestNotification);

// 친구 요청 보내기
router.post('/request', loginRequired, friendController.friendRequestSend);

// 친구 요청 수락
router.post('/accept', loginRequired, friendController.friendRequestAccept);

// 친구 요청 거절
router.post('/reject', loginRequired, friendController.friendRequestReject);

module.exports = router;