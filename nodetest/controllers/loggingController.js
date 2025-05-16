const fs = require('fs');
const path = require('path');
const logDir = path.join(__dirname, '../logs');
const logPath = path.join(logDir, 'user_actions.log');

// 디렉토리가 없으면 생성
if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
}

exports.logUserAction = (req, res) => {
    const userId = req.currentUserId || 'anonymous';
    const { action } = req.body;

    const log = {
        timestamp: new Date().toISOString(),
        userId,
        action,
        ip: req.ip,
        ua: req.headers['user-agent']
    };

    fs.appendFileSync(logPath, JSON.stringify(log) + '\n');
    res.json({ success: true });
};