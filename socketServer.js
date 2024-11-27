//서버 초기화 및 설정
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const axios = require('axios');
const cors = require('cors');

const chatController = require('./controllers/chatController');
const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes');
const logger = require('./logger');
const { RMessage } = require('./models/messageModel');

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


// 소켓 연결 처리
io.on('connection', (socket) => {
  console.log('user connected'); // 클라이언트가 연결되었을 때 로그 출력

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

  socket.on('sendMessage', async (data) => {
    console.log('Received data from client:', data); // 클라이언트로부터 받은 데이터를 로그로 출력 (수정된 부분)

    const { message_contents, r_id, u1_id, u2_id } = data;

    // 필수 값 검증
    if (!message_contents || !r_id || !u1_id || !u2_id) {
      let missingFields = [];
      if (!message_contents) missingFields.push('message_contents'); // 누락된 필드를 확인
      if (!r_id) missingFields.push('r_id');
      if (!u1_id) missingFields.push('u1_id');
      if (!u2_id) missingFields.push('u2_id');
      
      console.error(`Missing fields: ${missingFields.join(', ')}`); // 누락된 필드 로그 출력 (수정된 부분)
      socket.emit('errorMessage', `Missing fields: ${missingFields.join(', ')}`); // 클라이언트로 누락된 필드 전송 (수정된 부분)
      return;
    }

//    try {
//      // 소켓 서버에서 API 서버로 HTTP 요청 전송
//      const response = await axios.post('http://54.180.54.31:3000/api/messages', {
//        message_contents,
//        r_id,
//        u1_id,
//        u2_id,
//      });
//      console.log('API Response:', response.data); // API 서버 응답 출력 (수정된 부분)

      // API 서버 응답을 해당 방에 있는 클라이언트들에게 전송
//      io.to(r_id).emit('receiveMessage', response.data); // io.to(r_id)를 사용하여 특정 방에 전송 (수정된 부분)
//    } catch (error) {
//      console.error('Axios Request Error:', error.response?.data || error.message); // 에러 로그 출력 (수정된 부분)
//      socket.emit('errorMessage', 'Failed to send message'); // 클라이언트로 에러 메시지 전송 (수정된 부분)
//    }
//  });

  /*socket.on('assignMission', (data) => {
    missionController.assignMission(io, socket, data); // 미션 할당 처리
  });

  socket.on('completeMission', (data) => {
    missionController.completeMission(io, socket, data); // 미션 완료 처리
  });*/

  // 클라이언트가 연결 해제되었을 때 처리
//  socket.on('disconnect', () => {
//    console.log('User disconnected');
//  });
//});

// Sequelize를 사용하여 메시지 처리
//exports.sendMessage = async (io, socket, { message, r_id, u1_id, u2_id }) => {
//  const message_num = Math.random().toString(36).substr(2, 9); // 메시지 번호 생성
//  const send_date = new Date(); // 현재 시간

//  try {
//    // 메시지 저장
//    const newMessage = await RMessage.create({
//      u1_id,
//      u2_id,
//      r_id,
//      message_num,
//      message_contents: message,
//      send_date
//    });
//    console.log('Message saved to DB:', newMessage); // DB 저장 확인 로그 추가 (수정된 부분)

    // 클라이언트에 메시지 전송
//    socket.emit('receiveMessage', { 
//      u1_id, 
//      message, 
//      send_date: send_date.toISOString().slice(0, 19).replace('T', ' ') 
//    });
//  } catch (error) {
//    console.error('Error saving message to DB:', error.message); // DB 저장 실패 시 에러 로그 출력 (수정된 부분)
//  }
//};

try {
  // Sequelize를 사용하여 메시지 저장
  const newMessage = await RMessage.create({
    u1_id,
    u2_id,
    r_id,
    message_contents,
    send_date: new Date(), // 현재 시간 설정
  });
  console.log('DB 저장 성공:', newMessage); // DB 저장 확인 로그 추가

  // 메시지를 해당 방에 있는 클라이언트들에게 전송
  io.to(r_id).emit('receiveMessage', {
    u1_id,
    message_contents,
    send_date: newMessage.send_date.toISOString().slice(0, 19).replace('T', ' ')
  });
} catch (error) {
  console.error('DB 저장 오류:', error.message); // DB 저장 실패 시 에러 로그 출력
  socket.emit('errorMessage', 'Failed to save message to DB'); // 클라이언트로 에러 메시지 전송
}
});

// 클라이언트가 연결 해제되었을 때 처리
socket.on('disconnect', () => {
console.log('User disconnected');
});
});

server.listen(3001, () => {
  console.log('HTTP Server running on port 3001');
});