const users = new Map();

exports.addUser = (userId, ws) => {
  users.set(userId, ws);
  console.log(`✅ User ${userId} added`);
};

exports.removeUser = (ws) => {
  for (const [userId, socket] of users.entries()) {
    if (socket === ws) {
      users.delete(userId);
      console.log(`🗑️ User ${userId} removed`);
      break;
    }
  }
};

exports.sendToUser = (targetId, type, payload, from) => {
  console.log(`🟡 sendToUser() called`);
  console.log(`🔸 from: ${from}`);
  console.log(`🔸 targetId: ${targetId}`);
  console.log(`🔸 type: ${type}`);
  console.log(`🔸 payload: ${JSON.stringify(payload)}`);

  const targetSocket = users.get(targetId);

  console.log(`🔍 Current connected users: [${[...users.keys()].join(', ')}]`);

  if (targetSocket) {
    const message = {
      type,
      from,
      payload
    };
    console.log(`📨 Sending to ${targetId}: ${JSON.stringify(message)}`);
    targetSocket.send(JSON.stringify(message));
  } else {
    console.log(`❗ Target user ${targetId} not found`);
  }
};

exports.getUserId = (ws) => {
  for (const [userId, socket] of users.entries()) {
    if (socket === ws) {
      return userId;
    }
  }
  return null;
};

exports.getSocketById = (userId) => {
  return users.get(userId);
};
