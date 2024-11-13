const db = require('../config/db');

exports.createRoom = (socket, roomName) => {
  const roomId = Math.random().toString(36).substr(2, 9);
  socket.join(roomId);
  socket.emit('roomCreated', roomId);
};

exports.joinRoom = (socket, { roomId, userId }) => {
  socket.join(roomId);
  console.log(`User ${userId} joined room ${roomId}`);
};

exports.sendMessage = (io, socket, { roomId, message }) => {
  io.to(roomId).emit('receiveMessage', message);

  // 메시지를 데이터베이스에 저장
  db.query('INSERT INTO messages (room_id, message) VALUES (?, ?)', [roomId, message], (err, result) => {
    if (err) console.error('Error saving message:', err);
  });
};