const moment = require('moment-timezone');

// 시간 변환 미들웨어
const timeConverterMiddleware = (req, res, next) => {
    const originalJson = res.json;
    res.json = function (data) {
        if (data.missions) {
            data.missions = data.missions.map(mission => ({
                ...mission,
                m_deadline: moment(mission.m_deadline).tz('Asia/Seoul').format('YYYY-MM-DD HH:mm:ss'),
            }));
        }
        originalJson.call(this, data);
    };
    next();
};

module.exports = timeConverterMiddleware;