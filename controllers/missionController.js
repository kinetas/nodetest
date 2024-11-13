// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기

// 미션 생성 함수
exports.createMission = async (req, res) => {
    const { u1_id, u2_id, m_title, m_deadline, m_reword } = req.body;

    // 필수 값 검증
    if (!m_id || !u1_id || !u2_id) {
        return res.json({ success: false, message: '미션 ID, 생성자 ID, 받는 사용자 ID는 필수 항목입니다.' });
    }

    try {
        // 현재 최대 m_id 조회
        const maxMission = await Mission.findOne({
            attributes: [[sequelize.fn('MAX', sequelize.col('m_id')), 'max_m_id']]
        });
        const maxId = maxMission.dataValues.max_m_id || 0; // 현재 최대 m_id가 없으면 0으로 초기화
        const newMId = parseInt(maxId) + 1; // 새로운 m_id 값

        // 미션 생성 및 DB 저장
        await Mission.create({
            m_id: newMId.toString(),
            u1_id,
            u2_id,
            m_title,
            m_deadline,
            m_reword
        });

        res.json({ success: true, message: '미션이 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('미션 생성 오류:', error);
        res.status(500).json({ success: false, message: '미션 생성 중 오류가 발생했습니다.' });
    }
};

// 미션 리스트 조회 함수
exports.getUserMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;
        
        // 사용자 ID에 해당하는 미션 리스트 조회
        const missions = await Mission.findAll({
            where: { u1_id: userId }
        });
        
        res.json({ missions });
    } catch (error) {
        console.error('미션 리스트 조회 오류:', error);
        res.status(500).json({ message: '미션 리스트를 불러오는데 실패했습니다.' });
    }
};