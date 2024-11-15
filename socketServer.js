//서버 초기화 및 설정
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const chatController = require('./controllers/chatController');
//const https = require('https');
//const fs = require('fs');
const cors = require('cors');

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
    origin: ['http://43.203.233.135:3000', 'http://43.203.233.135:3001', 'http://localhost:3000', 'http://localhost:3001'],
    methods: ['GET', 'POST'],
  },
  path: '/socket.io'  // path 설정
});

app.use(cors());
app.use(express.json());
app.use('/auth', authRoutes);
app.use('/chat', chatRoutes);
app.use('/mission', missionRoutes);

//클라이언트에서 보내는 connect 이벤트 처리
io.on('connection', (socket) => {
  console.log('A user connected');

  socket.on('createRoom', (roomName) => {
    chatController.createRoom(socket, roomName);
  });

  socket.on('joinRoom', (data) => {
    chatController.joinRoom(socket, data);
  });

  socket.on('sendMessage', (data) => {
    chatController.sendMessage(io, socket, data);
  });

  socket.on('assignMission', (data) => {
    missionController.assignMission(io, socket, data);
  });

  socket.on('completeMission', (data) => {
    missionController.completeMission(io, socket, data);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

server.listen(3001, () => {
  console.log('HTTP Server running on port 3001');
});