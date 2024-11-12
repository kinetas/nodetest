// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기

// 미션 리스트 조회 함수
// exports.getUserMissions = async (req, res) => {
//     try {
//         const userId = req.session.user.id;
        
//         // 사용자 ID에 해당하는 미션 리스트 조회
//         const missions = await Mission.findAll({
//             where: { u1_id: userId }
//         });
        
//         res.json({ missions });
//     } catch (error) {
//         console.error('미션 리스트 조회 오류:', error);
//         res.status(500).json({ message: '미션 리스트를 불러오는데 실패했습니다.' });
//     }
// };

exports.getUserMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;
        console.log("조회할 사용자 ID:", userId); // 디버깅용

        const missions = await Mission.findAll({
            where: { u1_id: userId }
        });

        console.log("조회된 미션:", missions); // 디버깅용
        res.json({ missions });
    } catch (error) {
        console.error('미션 리스트 조회 오류:', error);
        res.status(500).json({ message: '미션 리스트를 불러오는데 실패했습니다.' });
    }
};