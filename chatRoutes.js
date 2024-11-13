const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authenticateToken = require('../auth');

// 채팅방 생성
router.post('/create-room', authenticateToken, chatController.createRoom);

// 채팅방 참여
router.post('/join-room', authenticateToken, chatController.joinRoom);

module.exports = router;