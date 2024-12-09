//서버 초기화 및 설정
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const axios = require('axios');
const cors = require('cors');
const notificationController = require('./controllers/notificationController');
const chatController = require('./controllers/chatController');
const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes');
const logger = require('./logger');
const RMessage  = require('./models/messageModel');
const multer = require('multer');
const Room  = require('./models/roomModel');
const app = express();
const server = http.createServer(app);

//socket.io 서버 초기화
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
    credentials: true //세션 쿠키 관리
  },
  path: '/socket.io'  // path 설정
});


app.use(cors());
app.use(express.json());
app.use('/auth', authRoutes);
app.use('/chat', chatRoutes);
app.use('/mission', missionRoutes);

const storage = multer.memoryStorage();
const upload = multer({ storage });

// //소켓 연결 처리
// io.on('connection', (socket) => {
//   console.log('A user connected');

//   socket.on('createRoom', (roomName) => {
//     chatController.createRoom(socket, roomName);
//   });

//   socket.on('joinRoom', (data) => {
//     chatController.joinRoom(socket, data);
//   });

//   socket.on('sendMessage', async (data) => {
//     const { message_contents, r_id, u1_id, u2_id } = data;
//     // if (!message_contents || !r_id || !u1_id || !u2_id) {
//     //   console.error(`소켓 서버에서 필수 값 누락 :`, data);
//     //   socket.emit('errorMessage', '필수 값이 누락되었습니다.');
//     //   return;
//     // }

//     if (!message_contents || !r_id || !u1_id || !u2_id) {
//       let missingFields = [];
      
//       if (!message_contents) missingFields.push('message_contents');
//       if (!r_id) missingFields.push('r_id');
//       if (!u1_id) missingFields.push('u1_id');
//       if (!u2_id) missingFields.push('u2_id');
      
//       console.error(`소켓 서버에서 필수 값 누락: ${missingFields.join(', ')}`);
//       socket.emit('errorMessage', `필수 값이 누락되었습니다: ${missingFields.join(', ')}`);
//       return;
//     }

//     try {
//       //소켓 서버에서 API 서버로 HTTP 요청 전송
//       const response = await axios.post('http://13.124.126.234:3000/api/messages', {
//         message_contents: data.message_contents,
//         r_id: data.r_id,
//         u1_id: data.u1_id,
//         u2_id: data.u2_id,
//       });

//   /*socket.on('assignMission', (data) => {
//     missionController.assignMission(io, socket, data);
//   });

//   socket.on('completeMission', (data) => {
//     missionController.completeMission(io, socket, data);
//   });
//   */

//  // 4. API 서버로부터의 응답을 소켓 서버가 받아 클라이언트로 전송
//     io.to(data.r_id).emit('receiveMessage', response.data);
//     } 
//     catch (error) {
//       console.error('Error sending message to API server:', error);
//       socket.emit('errorMessage', 'Failed to send message');
//     }
// });

//   socket.on('disconnect', () => {
//     console.log('User disconnected');
//   });
// });
const userSockets = new Map(); // 사용자 ID와 소켓 ID 매핑

// 소켓 연결 처리
io.on('connection', (socket) => {
  console.log('user connected'); // 클라이언트가 연결되었을 때 로그 출력

  const userId = socket.handshake.query.u1_id;
  if (userId) {
      userSockets.set(userId, socket.id);
  }
  socket.on('disconnect', () => {
    console.log('User disconnected');
    userSockets.delete(userId);
});

/*
  socket.on('createRoom', (roomName) => {
    chatController.createRoom(socket, roomName); // 방 생성 처리
  });

  socket.on('joinRoom', (data) => {
    chatController.joinRoom(socket, data, (error, result) => {
        if (error) {
            console.error(`Failed to join room: ${error.message}`);
        } else {
            console.log(`User ${result.u1_id} successfully joined room ${result.r_id}`);
        }
    });
});

//메시지 읽음 처리 실시간 반영
socket.on('markAsRead', async (data) => {
  const { r_id, u1_id } = data;
  try {
    const success = await chatController.markMessageAsRead({ r_id, u1_id });
    if (success) {
      io.to(r_id).emit('messageRead', { r_id, u1_id }); // 클라이언트에 읽음 상태 알림
      console.log(`Messages in room ${r_id} marked as read for user ${u1_id}`);
  } else {
      console.error("Failed to mark messages as read.");
  }
  } catch (error) {
    console.error("Socket markAsRead error:", error);
  }
});
*/
// 방 입장 처리
socket.on('joinRoom', async (data) => {
  let { r_id, u2_id } = data;
  const u1_id = data.u1_id || socket.handshake.query.u1_id;
  if (!u2_id) {
    const room = await Room.findOne({ where: { r_id } });
    u2_id = room ? room.u2_id : null;
}

if (!u1_id || !u2_id) {
    console.error('Invalid joinRoom data:', { r_id, u1_id, u2_id });
    return;
}
  try {
      // 소켓 방 참여
      socket.join(r_id);
      console.log(`User ${u1_id} joined room ${r_id}`);
      // 메시지 읽음 상태 갱신
      const updatedCount = await RMessage.update(
          { is_read: 0 },
          { where: { r_id, u2_id: u1_id, is_read: 1 } }
      );
      console.log(`Updated ${updatedCount} messages as read for room ${r_id}`);

      // 초기 메시지 로드
      //const messages = await chatController.getMessages(r_id);
      //socket.emit('initialMessages', messages);
  } catch (error) {
      console.error('Error in joinRoom:', error);
      socket.emit('errorMessage', 'Failed to join room or load messages');
  }
});

  socket.on('sendMessage', async (data) => {
    //console.log('Received data from client:', data); // 클라이언트로부터 받은 데이터를 로그로 출력 (수정된 부분)

    const { message_contents, r_id, u1_id, u2_id, image, image_type, is_read } = data;

    // 필수 값 검증
    if (!r_id || !u1_id || !u2_id||is_read) {
      let missingFields = [];
     // 누락된 필드를 확인
      if (!r_id) missingFields.push('r_id');
      if (!u1_id) missingFields.push('u1_id');
      if (!u2_id) missingFields.push('u2_id');
      if (!is_read) missingFields.push('is_read');
      if (missingFields.length > 0) {
      console.error(`누락된 필드: ${missingFields.join(', ')}`); // 누락된 필드 로그 출력 (수정된 부분)
      socket.emit('errorMessage', `필수 필드 누락: ${missingFields.join(', ')}`); // 클라이언트로 누락된 필드 전송 (수정된 부분)
      return;
    }
  }
  if (!message_contents && !image) {
    console.error('메시지와 파일이 모두 없습니다.');
    socket.emit('errorMessage', '메시지나 파일 중 하나는 반드시 포함되어야 합니다.');
    return;
}

try {
  let fileBuffer = null;

  // 이미지 데이터가 있는 경우 처리
  if (image) {
    try {
      fileBuffer = Buffer.from(image, 'base64');
    } catch (bufferError) {
      console.error('이미지를 버퍼로 변환 중 오류:', bufferError);
      socket.emit('errorMessage', '잘못된 이미지 데이터');
      return;
    }
  }
  // Sequelize를 사용하여 메시지 저장
  const newMessage = await RMessage.create({
    u1_id,
    u2_id,
    r_id,
    message_contents: message_contents || null, // 메시지가 없으면 null로 저장
    send_date: new Date(), // KST 시간 설정
    image: fileBuffer,
    image_type: image_type || null,
    is_read:1
  });
  //console.log('DB 저장 성공:', newMessage); // DB 저장 확인 로그 추가
    // 상대방 연결 상태 확인
    const receiverSocketId = userSockets.get(u2_id);
    const isReceiverConnected = receiverSocketId && io.sockets.sockets.get(receiverSocketId);
    if (isReceiverConnected) {
      await RMessage.update(
          { is_read: 0 },
          { where: { r_id, u2_id: u1_id, is_read: 1 } }
      );
      io.to(receiverSocketId).emit('messageRead', { r_id, u1_id });
  }
  
   // 메시지 브로드캐스트,  안전성 검사
  io.to(r_id).emit('receiveMessage', {
    u1_id,
    r_id,
    message_contents: message_contents || '[이미지]', // 클라이언트에서 기본 메시지
    send_date: newMessage.send_date,//여기서 보낼 때 시간 뜸
    image: fileBuffer ? fileBuffer.toString('base64') : null, // Base64로 인코딩하여 클라이언트에 전송
    is_read: newMessage.is_read
  });
  console.log(`Sending message to room ${r_id}:`, {
    u1_id,
    r_id,
    message_contents,
    send_date: newMessage.send_date,
    image: fileBuffer ? fileBuffer.toString('base64') : null,
    is_read
  });
  

  //상대방 소켓 연결 안되어있을시 FCM 알림 호출
  if (!isReceiverConnected) {
    console.log(`User ${u2_id} is offline, sending FCM notification`);
    const body = message_contents || '[이미지]';
    await notificationController.sendMessageNotification(u2_id, body);
}
  // 메시지 읽음 처리
  socket.on('markAsRead', async (data) => {
    const { r_id, u1_id } = data;

    try {
        const success = await RMessage.update(
            { is_read: 0 },
            { where: { r_id, u2_id: u1_id, is_read: 1 } }
        );
        if (success) {
            io.to(r_id).emit('messageRead', { r_id, u1_id });
        }
    } catch (error) {
        console.error('Error in markAsRead:', error);
    }
});

} catch (error) {
  console.error('DB 저장 오류:', error); // DB 저장 실패 시 에러 로그 출력
  if (error.name === 'SequelizeValidationError') {
    error.errors.forEach((err) => {
      console.error(`Validation Error - Field: ${err.path}, Message: ${err.message}`);
    });
  } else {
    console.error('오류 종류:', error.name); // 다른 유형의 오류도 확인할 수 있도록 처리합니다.
  }
  socket.emit('errorMessage', 'Failed to save message to DB'); // 클라이언트로 에러 메시지 전송
}
});
//
// 클라이언트가 연결 해제되었을 때 처리
/*
socket.on('disconnect', () => {
console.log('User disconnected');
});
*/
});

server.listen(3001, () => {
  console.log('HTTP Server running on port 3001');
});


// //=======================================================

// // ===== 추가된 부분 =====
// // sendMessage 함수 정의 및 내보내기
// const sendMessage = (data) => {
//   const { r_id, message_contents, u1_id, u2_id } = data;

//   io.to(r_id).emit('receiveMessage', {
//     u1_id,
//     u2_id,
//     message_contents,
//     send_date: new Date(),
//   });
// };

// // io, sendMessage, server 내보내기
// module.exports = { io, sendMessage, server };