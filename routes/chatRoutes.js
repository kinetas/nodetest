const express = require('express');
const router = express.Router();
const multer = require('multer');
const chatController = require('../controllers/chatController');
const authenticateToken = require('../auth');

const storage = multer.memoryStorage(); // 파일을 메모리에 저장
const upload = multer({ storage });

// 채팅방 생성
router.post('/create-room', authenticateToken, chatController.createRoom);

// 채팅방 참여
router.post('/join-room', authenticateToken, chatController.joinRoom);

// 채팅방에 사진 및 메시지 업로드
router.post('/send-message', authenticateToken, upload.single('file'), chatController.sendMessageWithFile);

router.get('/messages/:r_id', async (req, res) => {
    const { r_id } = req.params;
    try {
        const messages = await chatController.getMessages(r_id);
        res.json(messages);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
});
module.exports = router;