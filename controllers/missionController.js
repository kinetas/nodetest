// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기
const { sequelize } = require('../models/missionModel'); // sequelize 객체 불러오기
const Room = require('../models/roomModel'); // Room 모델 가져오기
const resultController = require('./resultController'); // resultController 가져오기
const { v4: uuidv4, validate: uuidValidate } = require('uuid');

// 미션 생성 함수
exports.createMission = async (req, res) => {
    const { u1_id, u2_id, m_title, m_deadline, m_reword } = req.body;

    // 필수 값 검증
    if (!u2_id) {
        return res.json({ success: false, message: '받는 사용자 ID는 필수 항목입니다.' });
    }

    try {
        // u1_id와 u2_id 조합의 Room이 존재하는지 확인
        const roomExists = await Room.findOne({ where: { u1_id, u2_id } });
        
        if (!roomExists) {
            return res.json({ success: false, message: '미션을 생성하기 전에 방이 존재해야 합니다.' });
        }

        // // 현재 최대 m_id 조회
        // const maxMission = await Mission.findOne({
        //     attributes: [[sequelize.fn('MAX', sequelize.col('m_id')), 'max_m_id']]
        // });
        // const maxId = maxMission.dataValues.max_m_id || 0; // 현재 최대 m_id가 없으면 0으로 초기화
        // const newMId = parseInt(maxId) + 1; // 새로운 m_id 값

        const missionId = uuidv4();
        if (!uuidValidate(missionId)) {
            console.error("생성된 UUID가 유효하지 않습니다.");
            res.status(500).json({ success: false, message: `생성된 UUID가 유효하지 않습니다.` });
            return; // 또는 throw new Error("유효하지 않은 UUID 생성");
        }
        
        let stat = "진행중";
        // 미션 생성 및 DB 저장
        await Mission.create({
            m_id: missionId,
            u1_id,
            u2_id,
            m_title,
            m_deadline,
            m_reword,
            m_status: stat
        });

        // m_result 테이블에 데이터 저장
        const u_id = u1_id; // 세션에서 로그인한 유저 ID 가져오기
        const result = await resultController.saveResult(missionId, u_id, m_deadline, stat);

        res.json({ success: true, message: '미션이 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('미션 생성 오류:', error);
        res.status(500).json({ success: false, message: `미션 생성 중 ${error}오류1가 발생했습니다.` });
    }
};

// 미션 삭제 함수
exports.deleteMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.session.user.id; // 세션에서 로그인한 사용자 ID 가져오기

    if (!m_id) {
        return res.json({ success: false, message: '미션 ID는 필수 항목입니다.' });
    }

    try {
        // 해당 m_id로 미션 조회
        const mission = await Mission.findOne({ where: { m_id, u1_id } });

        if (!mission) {
            // 미션이 존재하지 않거나, 해당 사용자의 미션이 아닌 경우
            return res.json({ success: false, message: '해당 미션이 존재하지 않거나 삭제 권한이 없습니다.' });
        }

        // 미션 삭제
        await mission.destroy();
        res.json({ success: true, message: '미션이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        console.error('미션 삭제 오류:', error);
        res.status(500).json({ success: false, message: '미션 삭제 중 오류가 발생했습니다.' });
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

// 미션 성공 처리 함수
exports.successMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.session.user.id;
    try {
        const mission = await Mission.findOne({ where: { m_id } });

        if (!mission) {
            return res.json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }
        
         // m_status가 "진행중"일 때만 상태 변경 가능
         if (mission.m_status !== '진행중') {
            return res.json({ success: false, message: '현재 상태에서는 미션을 성공으로 변경할 수 없습니다.' });
        }

        mission.m_status = '성공';
        await mission.save();

        res.json({ success: true, message: '미션이 성공으로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 성공 처리 오류:', error);
        res.status(500).json({ success: false, message: `미션 인증 성공 처리 중 ${error}오류가 발생했습니다.` });
    }
};

// 미션 실패 처리 함수
exports.failureMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.session.user.id;
    try {
        const mission = await Mission.findOne({ where: { m_id, u1_id } });

        if (!mission) {
            return res.json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        // m_status가 "진행중"일 때만 상태 변경 가능
        if (mission.m_status !== '진행중') {
            return res.json({ success: false, message: '현재 상태에서는 미션을 성공으로 변경할 수 없습니다.' });
        }

        mission.m_status = '실패';
        await mission.save();

        res.json({ success: true, message: '미션이 실패로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 실패 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 인증 실패 처리 중 오류가 발생했습니다.' });
    }
};
