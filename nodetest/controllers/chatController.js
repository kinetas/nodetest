// const db = require('../config/db');
const RMessage = require('../models/messageModel');
// const { sequelize } = require('../models/messageModel');
// const Room = require('../models/roomModel');

// =========================================token================================================
// const jwt = require('jsonwebtoken');
// const axios = require('axios');

// // ✅ JWT 토큰에서 userId 추출하는 유틸 함수
// async function getUserIdFromSocket(socket) {
//   try {
//     const token = socket.handshake.auth?.token;
    
//     console.log("🔑 수신된 토큰:", token); // 로그 추가
//     if (!token) {
//       console.error("❌ 토큰 누락(chatController:193)");
//       return null;
//     }
//     const secretKey = process.env.JWT_SECRET_KEY || "secret-key";
//     const decoded = jwt.verify(token, secretKey);
//     console.log("✅ 디코딩된 유저 ID:", decoded.userId); // 로그 추가
//     return decoded.userId;
//   } catch (err) {
//     console.error("❌ JWT 디코딩 실패(chatController:201):", err.message);
//     return null;
//   }
// }

// exports.createRoom = (socket, roomName) => {
//   const r_id = Math.random().toString(36).substr(2, 9);
//   const u1_id = socket.handshake.query.u1_id;
//   const u2_id = socket.handshake.query.u2_id;
//   const r_title = socket.handshake.query.r_title;

//   socket.join(r_id);
//   socket.emit('roomCreated', r_id);
// };


// exports.joinRoom = async (socket, { r_id, u2_id }) => {
//   try {
//     const u1_id = await getUserIdFromSocket(socket);
//     console.log("🧾 joinRoom - r_id:", r_id, " / u1_id:", u1_id, " / u2_id:", u2_id);
//     if (!r_id || !u1_id) {
//       console.error(`Missing r_id or u1_id:`, { r_id, u1_id });
//       return;
//     }

//     const room = await Room.findOne({ where: { r_id } });
//     if (!room) {
//       console.error(`Room with ID ${r_id} not found.`);
//       return;
//     }

//     const updatedCount = await RMessage.update(
//       { is_read: 0 },
//       { where: { r_id, u2_id: u1_id, is_read: 1 } }
//     );
//     if (updatedCount[0] === 0) {
//       console.warn(`No unread messages found for room ${r_id} and user ${u1_id}`);
//     }

//     socket.join(r_id);
//     console.log(`joined room ${r_id} by user ${u1_id}`);
//   } catch (error) {
//     console.error('Error joining room with Sequelize:', error);
//   }
// };

// exports.sendMessage = async (io, socket, { message, r_id, u2_id, image, image_type }) => {
//   const u1_id = await getUserIdFromSocket(socket);
//   const send_date = new Date();
//   const is_read = 1;
//   const message_num = Math.random().toString(36).substr(2, 9);

//   if (!r_id || !u1_id || !u2_id || (!message && !image)) {
//     console.error('Missing required fields:', { r_id, u1_id, u2_id, message });
//     return;
//   }

//   try {
//     const newMessage = await RMessage.create({
//       u1_id,
//       u2_id,
//       r_id,
//       message_num,
//       send_date,
//       message_contents: message || null,
//       image: image ? Buffer.from(image, 'base64') : null,
//       image_type: image_type || null,
//       is_read
//     });

//     console.log('Message saved:', newMessage);

//     socket.emit('receiveMessage', {
//       u1_id,
//       message_contents: message || '[파일 전송]',
//       // image,
//       image: image ? image.toString('base64') : null, // ✅ base64 인코딩
//       image_type: image_type || 'image/png',
//       is_read,
//       send_date: send_date.toISOString().slice(0, 19).replace('T', ' ')
//     });
//   } catch (error) {
//     console.error('Error saving message with Sequelize:', error);
//   }
// };

exports.getMessages = async (r_id) => {
  try {
    const messages = await RMessage.findAll({
      where: { r_id },
      order: [['send_date', 'ASC']]
    });
    // return messages.map(msg => msg.toJSON());

    return messages.map(msg => {
      const json = msg.toJSON();

      // ✅ image가 존재하면 base64로 변환
      if (json.image) {
        json.image = Buffer.from(json.image).toString('base64');
      }

      return json;
    });

  } catch (error) {
    console.error('Error fetching messages with Sequelize:', error);
    throw error;
  }
};

//채팅방에서 가장 최근 메시지를 가져오는 함수
exports.getLastMessage = async (r_id) => {
  try {
    const lastMessage = await RMessage.findOne({
      where: { r_id },
      order: [['send_date', 'DESC']]
    });

    // return lastMessage;
    return lastMessage.map(msg => {
      const json = msg.toJSON();

      // ✅ image가 존재하면 base64로 변환
      if (json.image) {
        json.image = Buffer.from(json.image).toString('base64');
      }

      return json;
    });
  } catch (error) {
    console.error('❌ 마지막 메시지 가져오기 오류:', error);
    throw error;
  }
};

// exports.markMessageAsRead = async ({ r_id }) => {
//   try {
//     const updatedCount = await RMessage.update(
//       { is_read: 0 },
//       { where: { r_id, is_read: 1 } }
//     );
//     console.log(`Updated ${updatedCount} messages as read.`);
//     return updatedCount > 0;
//   } catch (error) {
//     console.error("Error updating is_read:", error);
//     return false;
//   }
// };