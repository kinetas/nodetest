const userService = require('../services/userService');

exports.join = (ws, data) => {
  const { userId } = data.payload;
  console.log(`🔵 User joined: ${userId}`);
  userService.addUser(userId, ws);

  ws.send(JSON.stringify({
    type: 'joined',
    from: userId,
    payload: { message: 'You joined the signaling server.' }
  }));
};

exports.offer = (ws, data) => {
  const { targetId, payload, from } = data;
  console.log(`📤 Sending offer from ${from} to ${targetId}`);
  userService.sendToUser(targetId, 'offer', payload, from);
};

exports.answer = (ws, data) => {
  const { targetId, payload, from } = data;
  console.log(`📤 Sending answer from ${from} to ${targetId}`);
  userService.sendToUser(targetId, 'answer', payload, from);
};

exports.candidate = (ws, data) => {
  const { targetId, payload, from } = data;
  console.log(`📤 Sending candidate from ${from} to ${targetId}`);
  userService.sendToUser(targetId, 'candidate', payload, from);
};
