const express = require('express');
const router = express.Router();
const friendController = require('../controllers/friendController');
// const requireAuth = require('../middleware/authMiddleware'); // 세션 인증 미들웨어
const loginRequired = require('../middleware/loginRequired');   // JWT 인증 미들웨어
const fcmController = require('../controllers/fcmController'); 
const { keycloak } = require('../keycloak'); // ✅ Keycloak 추가

//==========================세션=============================
// // i_friend 리스트 출력
// router.get('/ifriends', requireAuth, friendController.printIFriend);

// // t_friend 리스트 출력
// router.get('/tfriends', requireAuth, friendController.printTFriend);

// // 친구 삭제
// router.delete('/delete', requireAuth, friendController.friendDelete);

// // 친구 요청 보내기
// router.post('/request', requireAuth, friendController.friendRequestSend,fcmController.sendFriendRequestNotification);

// // 친구 요청 수락
// router.post('/accept', requireAuth, friendController.friendRequestAccept,fcmController.sendFriendRequestNotification);

// // 친구 요청 거절
// router.post('/reject', requireAuth, friendController.friendRequestReject,fcmController.sendFriendRequestNotification);

//==============================Token======================================
// i_friend 리스트 출력
// router.get('/ifriends', loginRequired, friendController.printIFriend);

// t_friend 리스트 출력
// router.get('/tfriends', loginRequired, friendController.printTFriend);

// 친구 삭제
// router.delete('/delete', loginRequired, friendController.friendDelete);

// 친구 요청 보내기
// router.post('/request', loginRequired, friendController.friendRequestSend,fcmController.sendFriendRequestNotification);

// 친구 요청 수락
// router.post('/accept', loginRequired, friendController.friendRequestAccept,fcmController.sendFriendRequestNotification);

// 친구 요청 거절
// router.post('/reject', loginRequired, friendController.friendRequestReject,fcmController.sendFriendRequestNotification);

//====================KeyCloak====================
router.get('/ifriends', keycloak.protect(), friendController.printIFriend);
router.get('/tfriends', keycloak.protect(), friendController.printTFriend);
router.delete('/delete', keycloak.protect(), friendController.friendDelete);
router.post('/request', keycloak.protect(), friendController.friendRequestSend, fcmController.sendFriendRequestNotification);
router.post('/accept', keycloak.protect(), friendController.friendRequestAccept, fcmController.sendFriendRequestNotification);
router.post('/reject', keycloak.protect(), friendController.friendRequestReject, fcmController.sendFriendRequestNotification);

module.exports = router;