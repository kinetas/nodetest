const express = require('express');
const router = express.Router();
const multer = require('multer');
const chatController = require('../controllers/chatController');
const authenticateToken = require('../auth');

// ✅ JWT 인증 미들웨어
const loginRequired = require('../middleware/loginRequired');

const storage = multer.memoryStorage(); // 파일을 메모리에 저장
const upload = multer({ storage });

// // 채팅방 생성
// router.post('/create-room', authenticateToken, chatController.createRoom);

// // 채팅방 참여
// router.post('/join-room', authenticateToken, chatController.joinRoom);

//  // 채팅방에 사진 및 메시지 업로드
// router.post('/send-message', authenticateToken, upload.single('file'), chatController.sendMessageWithFile);

// router.get('/messages/:r_id', async (req, res) => {
//     const { r_id } = req.params;
//     console.log(`Received request to fetch messages for room ID: ${r_id}`); // 요청이 서버로 전달되었는지 확인하기 위한 로그
//     try {
//         const messages = await chatController.getMessages(r_id);
//         console.log('Messages fetched from database:', messages);
//         if (!messages) {
//             return res.status(404).json({ error: 'No messages found' }); // 메시지를 찾지 못했을 때 404 응답
//         }
//         res.json(messages);
//     } catch (error) {
//         console.error('Error fetching messages:', error);
//         res.status(500).json({ error: 'Failed to fetch messages' });
//     }
// });

// ✅ 채팅방 생성 - JWT 보호 적용
router.post('/create-room', loginRequired, chatController.createRoom);

// ✅ 채팅방 참여 - JWT 보호 적용
router.post('/join-room', loginRequired, chatController.joinRoom);

// ✅ 메시지 + 파일 전송 - JWT 보호 적용
//router.post('/send-message', loginRequired, upload.single('file'), chatController.sendMessageWithFile);

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