const axios = require('axios');

async function logUserAction(userId, action, req) {
    try {
        await axios.post('http://27.113.11.48:3000/api/logs/log-action', {
            userId,
            action,
        }, {
            headers: {
                Authorization: req.headers.authorization, // JWT 유지
            }
        });
    } catch (e) {
        console.error('🔴 로그 기록 실패:', e.message);
    }
}

module.exports = { logUserAction };