const CRoom = require('../models/comunity_roomModel'); // comunity_room 모델 가져오기
const Room = require('../models/roomModel'); // room 모델
const Mission = require('../models/missionModel'); // mission 모델
const { v4: uuidv4, validate: uuidValidate } = require('uuid');

// 첫 번째 조건: 커뮤니티 미션 생성
exports.createCommunityMission = async (req, res) => {
    const { cr_title } = req.body; // 제목 입력 받기
    const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
    const cr_num = uuidv4(); // 랜덤 값 생성
    const cr_status = "match";
    const m1_status = "0";
    const m2_status = "0";

    try {
        await CRoom.create({ u_id, cr_num, cr_title, cr_status, m1_status, m2_status });
        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 생성 오류:', error);
        res.status(500).json({ success: false, message: '커뮤니티 미션 생성 중 오류가 발생했습니다.' });
    }
};

// 두 번째 조건: 커뮤니티 미션 수락
exports.acceptCommunityMission = async (req, res) => {
    const { cr_num } = req.body; // 미션 번호 가져오기
    const u2_id = req.session.user.id; // 세션에서 사용자 ID 가져오기

    try {
        const mission = await CRoom.findOne({ where: { cr_num } });
        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.u_id === u2_id) {
            return res.status(403).json({ success: false, message: '본인이 생성한 미션은 수락할 수 없습니다.' });
        }

        // 커뮤니티 미션 업데이트
        await mission.update({ u2_id, cr_status: 'acc' });

        // Room 테이블에 데이터 생성
        await Room.create({ 
            u1_id: mission.u_id, 
            u2_id, 
            r_id: uuidv4(), 
            r_title: `${mission.cr_num}-${u2_id}`, 
            r_type: 'open' 
        });

        // Mission 테이블에 미션 생성
        const newMissionId1 = uuidv4();
        const newMissionId2 = uuidv4();
        const missionTitle = mission.cr_title;

        await Mission.create({
            m_id: newMissionId1,
            u1_id: mission.u_id,
            u2_id,
            m_title: missionTitle,
            m_deadline: null,
            m_reword: null,
            m_status: '진행중'
        });

        await Mission.create({
            m_id: newMissionId2,
            u1_id: u2_id,
            u2_id: mission.u_id,
            m_title: missionTitle,
            m_deadline: null,
            m_reword: null,
            m_status: '진행중'
        });

        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 수락되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 수락 오류:', error);
        res.status(500).json({ success: false, message: '커뮤니티 미션 수락 중 오류가 발생했습니다.' });
    }
};

// 세 번째 조건: 커뮤니티 미션 삭제
exports.deleteCommunityMission = async (req, res) => {
    const { cr_num } = req.body;
    const u_id = req.session.user.id;

    try {
        const mission = await CRoom.findOne({ where: { cr_num, u_id } });

        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.cr_status !== 'match') {
            return res.status(403).json({ success: false, message: 'match 상태의 미션만 삭제할 수 있습니다.' });
        }

        await mission.destroy();
        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 삭제 오류:', error);
        res.status(500).json({ success: false, message: '커뮤니티 미션 삭제 중 오류가 발생했습니다.' });
    }
};