const db = require('../config/db');
const RMessage = require('../models/messageModel');
const { sequelize } = require('../models/messageModel');
const Room = require('../models/roomModel');

// const jwt = require('jsonwebtoken'); // JWT 추가

exports.createRoom = (socket, roomName) => {
  const r_id = Math.random().toString(36).substr(2, 9);
  const u1_id = socket.handshake.query.u1_id;//클라이언트에서 전달된 user ID
  const u2_id = socket.handshake.query.u2_id;
  const r_title = socket.handshake.query.r_title;
  
  socket.join(r_id);
  
  socket.emit('roomCreated', r_id);
};

exports.joinRoom = async (socket, { r_id, u1_id }) => {
  try {
    if (!r_id || !u1_id) {
      console.error(`sMissing r_id or u1_id:`, { r_id, u1_id });
      return;
    }
    // 사용자가 방에 들어갔을 때 방에 사용자 정보 업데이트 또는 추가
    const room = await Room.findOne({ where: { r_id } });

    if (!room) {
      console.error(`Room with ID ${r_id} not found.`);
      return;
    }

    // 방에 사용자를 추가하거나 관련 작업을 수행할 수 있음
    await Room.update(
      { u2_id: u1_id },  // 사용자가 방에 참여했다고 업데이트
      { where: { r_id } }
    );

    // 소켓을 이용해 방에 참여시키기
    socket.join(r_id);
    console.log(`User ${u1_id} joined room ${r_id}`);
  } catch (error) {
    console.error('Error joining room with Sequelize:', error);
  }
};

// // ===== JWT 기반 채팅방 참여 =====
// exports.joinRoom = (req, res) => {
//   const token = req.headers.authorization?.split(' ')[1];
//   if (!token) {
//       return res.status(401).json({ message: '로그인이 필요합니다.' });
//   }

//   try {
//       const decoded = jwt.verify(token, process.env.JWT_SECRET);
//       const userId = decoded.id;

//       const { roomId } = req.body;
//       // 참여 로직
//       res.json({ message: `User ${userId} joined room ${roomId}` });
//   } catch (error) {
//       res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//   }
// };

exports.sendMessage = async (io, socket, { message, r_id, u1_id, u2_id }) => {
  const message_num = Math.random().toString(36).substr(2, 9); // 메시지 번호 생성
  const send_date = new Date(); // 현재 시간

  try {
      // 메시지 저장
      const newMessage = await RMessage.create({
          u1_id,
          u2_id,
          r_id,
          message_num,
          send_date,
          message_contents: message
      });

      // 성공적으로 저장된 경우 콘솔 로그
      console.log('Message saved:', newMessage);

      // 클라이언트에 메시지 전송
      socket.emit('receiveMessage', { u1_id, message, send_date: send_date.toISOString().slice(0, 19).replace('T', ' ') });
  } catch (error) {
      console.error('Error saving message with Sequelize:', error);
  }
};

//메시지 불러오기
exports.getMessages = async (r_id) => {
  try {
    // 메시지 조회
    const messages = await RMessage.findAll({
      where: { r_id },
      order: [['send_date', 'ASC']],
    });

    // 메시지 반환
    return messages;
  } catch (error) {
    console.error('Error fetching messages with Sequelize:', error);
    throw error; // 오류가 발생하면 throw하여 호출한 쪽에서 처리
  }
};