const fs = require('fs');
const path = require('path');
const logPath = path.join(__dirname, '../logs/user_actions.log');

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