const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const signalingController = require('./controllers/signalingController');
const userService = require('./services/userService');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/ws' });

wss.on('connection', (ws) => {
  console.log('✅ New WebSocket connection');

  ws.on('message', (message) => {
    console.log(`📥 Received: ${message}`);
    const data = JSON.parse(message);

    switch (data.type) {
      case 'join':
       signalingController.join(ws, data);
        break;
      case 'offer':
        signalingController.offer(ws, data);
        break;
      case 'answer':
        signalingController.answer(ws, data);
        break;
      case 'candidate':
        signalingController.candidate(ws, data);
        break;
    }
  });

  ws.on('close', () => {
    console.log('❌ Client disconnected');
    userService.removeUser(ws);
  });
});

server.listen(3005, () => {
  console.log('🚀 WebRTC Signaling Server running on port 3005');
});
