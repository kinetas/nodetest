const express = require('express');
const router = express.Router();
const multer = require('multer');
const chatController = require('../controllers/chatController');

// ✅ JWT 인증 미들웨어
const loginRequired = require('../middleware/loginRequired');

const storage = multer.memoryStorage(); // 파일을 메모리에 저장
// const upload = multer({ storage });

// // ✅ 채팅방 생성 - JWT 보호 적용
// router.post('/create-room', loginRequired, chatController.createRoom);

// // ✅ 채팅방 참여 - JWT 보호 적용
// router.post('/join-room', loginRequired, chatController.joinRoom);

// ✅ 메시지 + 파일 전송 - JWT 보호 적용
// router.post('/send-message', loginRequired, upload.single('file'), chatController.sendMessageWithFile);

// ✅ 메시지 목록 조회 - 로그인 필요 없음 (로그인 필요할 경우 loginRequired 추가)
router.get('/messages/:r_id', async (req, res) => {
  const { r_id } = req.params;
  console.log(`Received request to fetch messages for room ID: ${r_id}`);
  try {
    const messages = await chatController.getMessages(r_id);
    if (!messages) {
      return res.status(404).json({ error: 'No messages found' });
    }
    res.json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

module.exports = router;