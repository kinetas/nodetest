const mysql = require('mysql');
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'chat_app'
});

db.connect((err) => {
  if (err) throw err;
  console.log('Database connected');
});

function saveMessage(roomId, userId, message) {
  const sql = 'INSERT INTO messages (roomId, userId, message) VALUES (?, ?, ?)';
  db.query(sql, [roomId, userId, message], (err, result) => {
    if (err) throw err;
    console.log('Message saved:', result);
  });
}

// Call saveMessage whenever a message is sent
socket.on('sendMessage', ({ roomId, userId, message }) => {
  io.to(roomId).emit('receiveMessage', message);
  saveMessage(roomId, userId, message); // Save the message in DB
});