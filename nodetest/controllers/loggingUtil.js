const fs = require('fs');
const path = require('path');

const logDir = path.join(__dirname, '../logs');
const logPath = path.join(logDir, 'user_actions.log');

if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
}

function logUserAction(userId, action, req) {
    const log = {
        timestamp: new Date().toISOString(),
        userId,
        action,
        ip: req.ip,
        ua: req.headers['user-agent']
    };

    fs.appendFileSync(logPath, JSON.stringify(log) + '\n');
}

module.exports = { logUserAction };