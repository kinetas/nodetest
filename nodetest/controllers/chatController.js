const db = require('../config/db');
const RMessage = require('../models/messageModel');
const { sequelize } = require('../models/messageModel');
const Room = require('../models/roomModel');

// exports.createRoom = (socket, roomName) => {
//   const r_id = Math.random().toString(36).substr(2, 9);
//   const u1_id = socket.handshake.query.u1_id;//클라이언트에서 전달된 user ID
//   const u2_id = socket.handshake.query.u2_id;
//   const r_title = socket.handshake.query.r_title;
  
//   socket.join(r_id);
  
//   socket.emit('roomCreated', r_id);
// };
// //
// exports.joinRoom = async (socket, { r_id, u2_id }) => {
//   try {
//     const u1_id = socket.handshake.query.u1_id || socket.handshake.auth.u1_id;
//     const u2_id = socket.handshake.query.u1_id || socket.handshake.auth.u2_id;
//     if (!r_id || !u1_id) {
//       console.error(`Missing r_id or u2_id:`, { r_id, u2_id });
//       return;
//     }
//     // 사용자가 방에 들어갔을 때 방에 사용자 정보 업데이트 또는 추가
//     const room = await Room.findOne({ where: { r_id } });

//     if (!room) {
//       console.error(`Room with ID ${r_id} not found.`);
//       return;
//     }
//     // 방에 사용자를 추가하거나 관련 작업을 수행할 수 있음
//     const updatedCount = await RMessage.update(
//       { is_read: 0 },
//       { where: { r_id, u2_id: u1_id, is_read: 1 } }
//   );
//   if (updatedCount[0] === 0) {
//     console.warn(`No unread messages found for room ${r_id} and user ${u1_id}`);
// }
//     // 소켓을 이용해 방에 참여시키기
//     socket.join(r_id);
//     console.log(`joined room ${r_id}`);
//   } catch (error) {
//     console.error('Error joining room with Sequelize:', error);
//   }
// };
// exports.sendMessage = async (io, socket, { message, r_id, u1_id, u2_id }) => {
//   //const message_num = Math.random().toString(36).substr(2, 9); // 메시지 번호 생성
//   const send_date = new Date(); // 현재 시간
//   if (!r_id || !u1_id ||!u2_id ||!message) {
//     console.error('Missing r_id or u1_id:', { r_id, u1_id,u2_id,message });
//     return;
//   }
//   console.log('Debugging variables:', { r_id, u1_id, u2_id, message,message_num, send_date });
//   try {
//       // 메시지 저장
//       const newMessage = await RMessage.create({
//           u1_id,
//           u2_id,
//           r_id,
//           message_num,
//           send_date,
//           message_contents: message,
//           is_read
//       });

//       // 성공적으로 저장된 경우 콘솔 로그
//       console.log('Message saved:', newMessage);

//       // 클라이언트에 메시지 전송
//       socket.emit('receiveMessage', { u1_id, message, is_read, send_date: send_date.toISOString().slice(0, 19).replace('T', ' ') });
//   } catch (error) {
//       console.error('Error saving message with Sequelize:', error);
//   }
// };

// exports.sendMessageWithFile = async (req, res) => {
//   const { u1_id, u2_id, r_id, message_contents, is_read } = req.body;
//   const file = req.file;

//   if (!u1_id || !u2_id || !r_id || !is_read ||(!message_contents && !file)) {
//       return res.status(400).json({ message: '필수 값이 누락되었습니다.' });
//   }

//   try {
//       let fileBuffer = null;
//       let fileType = null;

//       if (file) {
//           fileBuffer = file.buffer; // 변경된 부분 - 파일 처리 로직 추가
//           fileType = file.mimetype;
//       }

//       const newMessage = await RMessage.create({
//           u1_id,
//           u2_id,
//           r_id,
//           message_contents,
//           send_date: new Date(),
//           image: fileBuffer,
//           image_type: fileType,
//           is_read
//       }); // 변경된 부분 - 메시지와 파일을 DB에 저장

//       res.json({ message: '메시지와 파일이 성공적으로 저장되었습니다.', newMessage });
//   } catch (error) {
//       console.error('Error saving message to DB:', error);
//       res.status(500).json({ message: '메시지 저장 실패' });
//   }
// };

// //메시지 불러오기
// exports.getMessages = async (r_id) => {
//   try {
//     // 메시지 조회
//     const messages = await RMessage.findAll({
//       where: { r_id },
//       order: [['send_date', 'ASC']],
//     });

//     // Sequelize 객체를 JSON으로 변환
//     const jsonMessages = messages.map(msg => msg.toJSON());
//     //console.log(JSON.stringify(jsonMessages));
//     return jsonMessages; // JSON 데이터 반환
//   } catch (error) {
//     console.error('Error fetching messages with Sequelize:', error);
//     throw error; // 오류가 발생하면 throw하여 호출한 쪽에서 처리
//   }
// };
// //메시지 읽음 처리
// exports.markMessageAsRead = async ({ r_id}) => {
//   try {
//       const updatedCount =await RMessage.update(
//           { is_read: 0 },
//           { where: { r_id, is_read: 1 } } // 받은 메시지만 업데이트
//       );
//       console.log(`Updated ${updatedCount} messages as read.`);
//       return updatedCount > 0; // 업데이트 성공 여부 반환
//   } catch (error) {
//       console.error("Error updating is_read:", error);
//       return false;
//   }
// };

// =========================================token================================================
const jwt = require('jsonwebtoken');
const axios = require('axios');

// ✅ JWT 토큰에서 userId 추출하는 유틸 함수
async function getUserIdFromSocket(socket) {
  try {
    const token = socket.handshake.auth?.token;
    
    console.log("🔑 수신된 토큰:", token); // 로그 추가
    if (!token) {
      console.error("❌ 토큰 누락(chatController:193)");
      return null;
    }
    const secretKey = process.env.JWT_SECRET_KEY || "secret-key";
    const decoded = jwt.verify(token, secretKey);
    console.log("✅ 디코딩된 유저 ID:", decoded.userId); // 로그 추가
    return decoded.userId;
  } catch (err) {
    console.error("❌ JWT 디코딩 실패(chatController:201):", err.message);
    return null;
  }
}

exports.createRoom = (socket, roomName) => {
  const r_id = Math.random().toString(36).substr(2, 9);
  const u1_id = socket.handshake.query.u1_id;
  const u2_id = socket.handshake.query.u2_id;
  const r_title = socket.handshake.query.r_title;

  socket.join(r_id);
  socket.emit('roomCreated', r_id);
};


exports.joinRoom = async (socket, { r_id, u2_id }) => {
  try {
    const u1_id = await getUserIdFromSocket(socket);
    console.log("🧾 joinRoom - r_id:", r_id, " / u1_id:", u1_id, " / u2_id:", u2_id);
    if (!r_id || !u1_id) {
      console.error(`Missing r_id or u1_id:`, { r_id, u1_id });
      return;
    }

    const room = await Room.findOne({ where: { r_id } });
    if (!room) {
      console.error(`Room with ID ${r_id} not found.`);
      return;
    }

    const updatedCount = await RMessage.update(
      { is_read: 0 },
      { where: { r_id, u2_id: u1_id, is_read: 1 } }
    );
    if (updatedCount[0] === 0) {
      console.warn(`No unread messages found for room ${r_id} and user ${u1_id}`);
    }

    socket.join(r_id);
    console.log(`joined room ${r_id} by user ${u1_id}`);
  } catch (error) {
    console.error('Error joining room with Sequelize:', error);
  }
};

exports.sendMessage = async (io, socket, { message, r_id, u2_id, image, image_type }) => {
  const u1_id = await getUserIdFromSocket(socket);
  const send_date = new Date();
  const is_read = 1;
  const message_num = Math.random().toString(36).substr(2, 9);

  if (!r_id || !u1_id || !u2_id || (!message && !image)) {
    console.error('Missing required fields:', { r_id, u1_id, u2_id, message });
    return;
  }

  try {
    const newMessage = await RMessage.create({
      u1_id,
      u2_id,
      r_id,
      message_num,
      send_date,
      message_contents: message || null,
      image: image ? Buffer.from(image, 'base64') : null,
      image_type: image_type || null,
      is_read
    });

    console.log('Message saved:', newMessage);

    socket.emit('receiveMessage', {
      u1_id,
      message_contents: message || '[파일 전송]',
      // image,
      image: image ? image.toString('base64') : null, // ✅ base64 인코딩
      image_type: image_type || 'image/png',
      is_read,
      send_date: send_date.toISOString().slice(0, 19).replace('T', ' ')
    });
  } catch (error) {
    console.error('Error saving message with Sequelize:', error);
  }
};

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

exports.markMessageAsRead = async ({ r_id }) => {
  try {
    const updatedCount = await RMessage.update(
      { is_read: 0 },
      { where: { r_id, is_read: 1 } }
    );
    console.log(`Updated ${updatedCount} messages as read.`);
    return updatedCount > 0;
  } catch (error) {
    console.error("Error updating is_read:", error);
    return false;
  }
};


// exports.joinRoom = async (socket, { r_id, u2_id }) => {
//   try {
//     const u1_id = socket.handshake.query.u1_id || socket.handshake.auth.u1_id;
//     const u2_id = socket.handshake.query.u1_id || socket.handshake.auth.u2_id;

//     if (!r_id || !u1_id) {
//       console.error(`Missing r_id or u2_id:`, { r_id, u2_id });
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
//     console.log(`joined room ${r_id}`);
//   } catch (error) {
//     console.error('Error joining room with Sequelize:', error);
//   }
// };

// exports.sendMessage = async (io, socket, { message, r_id, u1_id, u2_id }) => {
//   const send_date = new Date();
//   const is_read = 1;
//   const message_num = Math.random().toString(36).substr(2, 9);

//   if (!r_id || !u1_id || !u2_id || !message) {
//     console.error('Missing r_id or u1_id:', { r_id, u1_id, u2_id, message });
//     return;
//   }

//   console.log('Debugging variables:', { r_id, u1_id, u2_id, message, message_num, send_date });

//   try {
//     const newMessage = await RMessage.create({
//       u1_id,
//       u2_id,
//       r_id,
//       message_num,
//       send_date,
//       message_contents: message,
//       is_read
//     });

//     console.log('Message saved:', newMessage);

//     socket.emit('receiveMessage', {
//       u1_id,
//       message,
//       is_read,
//       send_date: send_date.toISOString().slice(0, 19).replace('T', ' ')
//     });
//   } catch (error) {
//     console.error('Error saving message with Sequelize:', error);
//   }
// };

// exports.sendMessageWithFile = async (req, res) => {
//   const { u1_id, u2_id, r_id, message_contents, is_read } = req.body;
//   const file = req.file;

//   if (!u1_id || !u2_id || !r_id || !is_read || (!message_contents && !file)) {
//     return res.status(400).json({ message: '필수 값이 누락되었습니다.' });
//   }

//   try {
//     let fileBuffer = null;
//     let fileType = null;

//     if (file) {
//       fileBuffer = file.buffer;
//       fileType = file.mimetype;
//     }

//     const newMessage = await RMessage.create({
//       u1_id,
//       u2_id,
//       r_id,
//       message_contents,
//       send_date: new Date(),
//       image: fileBuffer,
//       image_type: fileType,
//       is_read
//     });

//     res.json({ message: '메시지와 파일이 성공적으로 저장되었습니다.', newMessage });
//   } catch (error) {
//     console.error('Error saving message to DB:', error);
//     res.status(500).json({ message: '메시지 저장 실패' });
//   }
// };

// exports.getMessages = async (r_id) => {
//   try {
//     const messages = await RMessage.findAll({
//       where: { r_id },
//       order: [['send_date', 'ASC']]
//     });

//     const jsonMessages = messages.map(msg => msg.toJSON());
//     return jsonMessages;
//   } catch (error) {
//     console.error('Error fetching messages with Sequelize:', error);
//     throw error;
//   }
// };

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