const moment = require('moment-timezone');

// // 시간 변환 미들웨어
// const timeConverterMiddleware = (req, res, next) => {
//     const originalJson = res.json;
//     res.json = function (data) {
//         if (data.missions) {
//             data.missions = data.missions.map(mission => ({
//                 ...mission,
//                 m_deadline: moment(mission.m_deadline).tz('Asia/Seoul').format('YYYY-MM-DD HH:mm:ss'),
//             }));
//         }
//         originalJson.call(this, data);
//     };
//     next();
// };

// 시간 변환 미들웨어
const timeConverterMiddleware = (req, res, next) => {
    const originalJson = res.json;
    res.json = function (data) {
        const convertDateFields = (item, dateFields) => {
            dateFields.forEach(field => {
                if (item[field]) {
                    item[field] = moment(item[field]).tz('Asia/Seoul').format('YYYY-MM-DD HH:mm:ss');
                }
            });
            return item;
        };

        // 모델별로 변환해야 하는 시간 필드 지정
        const modelDateFields = {
            c_v_notdup: [],
            CComment: [],
            comunityRooms: ['deadline'], // 예시 필드
            comunityVotes: ['c_deletedate'],
            CWrite: [],
            iFriends: [], // 시간 필드 없음
            MRecoCount: [],
            MRecommand: [],
            mResults: ['m_deadline'],
            RMessage: ['send_date'],
            missions: ['m_deadline', 'vote_create_date'],
            messages: ['send_date'],
            NotificationLog: [],
            rooms: [], // 시간 필드 없음
            TFriend: [],
            User: ['u_birth'],
        };

        // 데이터 변환 처리
        Object.keys(modelDateFields).forEach(modelName => {
            if (data[modelName]) {
                data[modelName] = data[modelName].map(item =>
                    convertDateFields(item, modelDateFields[modelName])
                );
            }
        });

        originalJson.call(this, data);
    };
    next();
};

module.exports = timeConverterMiddleware;