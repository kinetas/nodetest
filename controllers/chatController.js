const db = require('../config/db');

exports.createRoom = (socket, roomName) => {
  const roomId = Math.random().toString(36).substr(2, 9);
  socket.join(roomId);
  
  // 방 제목과 함께 room 테이블에 저장
  db.query('INSERT INTO room (u1_id, u2_id, r_title, r_type) VALUES (?, ?, ?, ?)', 
    [u1_id, u2_id, roomName, 'public'],  // 예시로 'public' 방 유형을 설정
    (err, result) => {
      if (err) {
        console.error('Error creating room:', err);
      } else {
        console.log('Room created:', result);
      }
  });

  socket.emit('roomCreated', roomId);
};

exports.joinRoom = (socket, { roomId, userId }) => {
  socket.join(roomId);
  console.log(`User ${userId} joined room ${roomId}`);
};

exports.sendMessage = (io, socket, { roomId, message, u1_id, u2_id }) => {
  io.to(roomId).emit('receiveMessage', message);

  // 메시지를 r_message 테이블에 저장
  const message_num = Math.random().toString(36).substr(2, 9);  // 메시지 번호 생성
  const send_date = new Date().toISOString(); // 현재 시간
  
  db.query('INSERT INTO r_message (u1_id, u2_id, message_num, send_date, message_contents) VALUES (?, ?, ?, ?, ?)',
    [u1_id, u2_id, message_num, send_date, message],
    (err, result) => {
      if (err) {
        console.error('Error saving message:', err);
      } else {
        console.log('Message saved to r_message:', result);
      }
  });
};