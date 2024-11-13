//서버 초기화 및 설정
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const https = require('https');
const fs = require('fs');
const cors = require('cors');

const db = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const chatRoutes = require('./routes/chatRoutes');
const missionRoutes = require('./routes/missionRoutes');
const logger = require('./logger');

const app = express();
const server = https.createServer({
  key: fs.readFileSync('/path/to/private-key.pem'),
  cert: fs.readFileSync('/path/to/certificate.pem')
}, app);
const io = socketIo(server, {
  cors: {
    origin: 'https://yourdomain.com',  // 여기다가 도메인 설정해보자
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());
app.use('/auth', authRoutes);
app.use('/chat', chatRoutes);
app.use('/mission', missionRoutes);

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

server.listen(443, () => {
  console.log('HTTPS Server running on port 443');
});