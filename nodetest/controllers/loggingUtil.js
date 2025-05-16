const fs = require('fs');
const path = require('path');

const logPath = path.join(process.cwd(), 'user_actions.log');

function logUserAction(userId, action, req) {
    try {
        const log = {
            timestamp: new Date().toISOString(),
            userId: userId || 'unknown',
            action: action || 'unknown',
            ip: (req && req.ip) || 'unknown_ip',
            ua: (req && req.headers && req.headers['user-agent']) || 'unknown_ua'
        };

        fs.appendFileSync(logPath, JSON.stringify(log) + '\n');
        console.log(`✅ 로그 기록됨:`, log);
    } catch (e) {
        console.error('❌ 로그 기록 실패:', e.message);
    }
}

module.exports = { logUserAction };