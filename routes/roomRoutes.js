// routes/roomRoutes.js
const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');

router.get('/', roomController.getRooms);
router.post('/', roomController.addRoom);
router.post('/enter', roomController.enterRoom)
router.delete('/:u2_id', roomController.deleteRoom);
// 방 이름 변경 라우트 추가
router.put('/update', roomController.updateRoomName);

module.exports = router;