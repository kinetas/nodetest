const fs = require('fs');
const path = require('path');

const logPath = path.join(process.cwd(), 'user_actions.log');;

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