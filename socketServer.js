//서버 초기화 및 설정
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const axios = require('axios');
//const https = require('https');
//const fs = require('fs');
const cors = require('cors');

const chatController = require('./controllers/chatController');
const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes');
const logger = require('./logger');

const app = express();
const server = http.createServer(/*{
  key: fs.readFileSync('/path/to/private-key.pem'),
  cert: fs.readFileSync('/path/to/certificate.pem')
},*/ app);

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

//소켓 연결 처리
io.on('connection', (socket) => {
  console.log('A user connected');

  socket.on('createRoom', (roomName) => {
    chatController.createRoom(socket, roomName);
  });

  socket.on('joinRoom', (data) => {
    chatController.joinRoom(socket, data);
  });

  // socket.on('sendMessage', async (data) => {
  //   const { message_contents, r_id, u1_id, u2_id } = data;
  //   // if (!message_contents || !r_id || !u1_id || !u2_id) {
  //   //   console.error(`소켓 서버에서 필수 값 누락 :`, data);
  //   //   socket.emit('errorMessage', '필수 값이 누락되었습니다.');
  //   //   return;
  //   // }

  //   if (!message_contents || !r_id || !u1_id || !u2_id) {
  //     let missingFields = [];
      
  //     if (!message_contents) missingFields.push('message_contents');
  //     if (!r_id) missingFields.push('r_id');
  //     if (!u1_id) missingFields.push('u1_id');
  //     if (!u2_id) missingFields.push('u2_id');
      
  //     console.error(`소켓 서버에서 필수 값 누락: ${missingFields.join(', ')}`);
  //     socket.emit('errorMessage', `필수 값이 누락되었습니다: ${missingFields.join(', ')}`);
  //     return;
  //   }

  //   try {
  //     //소켓 서버에서 API 서버로 HTTP 요청 전송
  //     const response = await axios.post('http://13.124.126.234:3000/api/messages', {
  //       message_contents: data.message_contents,
  //       r_id: data.r_id,
  //       u1_id: data.u1_id,
  //       u2_id: data.u2_id,
  //     });

  socket.on('sendMessage', async (data) => {
    console.log('Received data:', data);
  
    const { message_contents, r_id, u1_id, u2_id } = data;
  
    if (!message_contents || !r_id || !u1_id || !u2_id) {
      let missingFields = [];
  
      if (!message_contents) missingFields.push('message_contents');
      if (!r_id) missingFields.push('r_id');
      if (!u1_id) missingFields.push('u1_id');
      if (!u2_id) missingFields.push('u2_id');
  
      console.error(`Missing fields: ${missingFields.join(', ')}`);
      socket.emit('errorMessage', `Missing fields: ${missingFields.join(', ')}`);
      return;
    }
  
    try {
      const response = await axios.post('http://13.124.126.234:3000/api/messages', data);
      console.log('API Response:', response.data);
  
      io.to(r_id).emit('receiveMessage', response.data);
    } catch (error) {
      console.error('Error:', error.response?.data || error.message);
      socket.emit('errorMessage', 'Failed to process message');
    }
  });
  

  /*socket.on('assignMission', (data) => {
    missionController.assignMission(io, socket, data);
  });

  socket.on('completeMission', (data) => {
    missionController.completeMission(io, socket, data);
  });
  */

 // 4. API 서버로부터의 응답을 소켓 서버가 받아 클라이언트로 전송
    io.to(data.r_id).emit('receiveMessage', response.data);
    } 
    catch (error) {
      console.error('Error sending message to API server:', error);
      socket.emit('errorMessage', 'Failed to send message');
    }
});

  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

server.listen(3001, () => {
  console.log('HTTP Server running on port 3001');
});