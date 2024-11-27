// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기
//const { sequelize } = require('../models/missionModel'); // sequelize 객체 불러오기
const Room = require('../models/roomModel'); // Room 모델 가져오기
const resultController = require('./resultController'); // resultController 가져오기
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // Sequelize의 연산자 가져오기

// const jwt = require('jsonwebtoken'); // JWT 추가

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

// // 미션 생성 함수도 JWT 기반으로 변경
// exports.createMission = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const u1_id = decoded.id; // 토큰에서 u1_id 추출
//         const { u2_id, m_title, m_deadline, m_reword } = req.body;

//         const missionId = uuidv4();
//         if (!uuidValidate(missionId)) {
//             return res.status(500).json({ message: '유효하지 않은 UUID 생성' });
//         }

//         await Mission.create({
//             m_id: missionId,
//             u1_id,
//             u2_id,
//             m_title,
//             m_deadline,
//             m_reword,
//             m_status: '진행중',
//         });

//         res.json({ message: '미션이 성공적으로 생성되었습니다.' });
//     } catch (error) {
//         res.status(500).json({ message: '미션 생성 중 오류가 발생했습니다.' });
//     }
// };


// 미션 삭제 함수
exports.deleteMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.session.user.id; // 세션에서 로그인한 사용자 ID 가져오기

    if (!m_id) {
        return res.json({ success: false, message: '미션 ID는 필수 항목입니다.' });
    }

    try {
        // 특정 m_id와 u1_id로 삭제할 미션을 직접 지정하여 삭제
        const deletedCount = await Mission.destroy({ where: { m_id, u1_id } });

        if (deletedCount === 0) {
            // 미션이 존재하지 않거나, 해당 사용자의 미션이 아닌 경우
            return res.json({ success: false, message: '해당 미션이 존재하지 않거나 삭제 권한이 없습니다.' });
        }
        
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

// 자신이 수행해야 할 미션 목록 (u2_id = userId)
exports.getAssignedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const assignedMissions = await Mission.findAll({
            where: {
                u2_id: userId, // 자신이 수행해야 할 미션
            },
        });

        res.json({ missions: assignedMissions });
    } catch (error) {
        console.error('자신이 수행해야 할 미션 조회 오류:', error);
        res.status(500).json({ message: '수행해야 할 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 부여한 미션 목록 (u1_id = userId)
exports.getCreatedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const createdMissions = await Mission.findAll({
            where: {
                u1_id: userId,
                u2_id: {
                    [Op.ne]: userId, // 자신이 자신에게 부여한 미션은 제외
                },
            },
        });

        res.json({ missions: createdMissions });
    } catch (error) {
        console.error('자신이 부여한 미션 조회 오류:', error);
        res.status(500).json({ message: '부여한 미션을 불러오는데 실패했습니다.' });
    }
};


// // ===== JWT 기반 미션 조회 =====
// exports.getUserMissions = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const userId = decoded.id;

//         const missions = await Mission.findAll({
//             where: { u1_id: userId },
//         });

//         res.json({ missions });
//     } catch (error) {
//         return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//     }
// };


// 미션 성공 처리 함수
exports.successMission = async (req, res) => {
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

        await Mission.update(
            { m_status: '성공' },
            { where: { m_id, u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
        );
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

        await Mission.update(
            { m_status: '실패' },
            { where: { m_id, u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
        );

        res.json({ success: true, message: '미션이 실패로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 실패 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 인증 실패 처리 중 오류가 발생했습니다.' });
    }
};

//방미션출력
exports.printRoomMission = async (req, res) => {
    const { u2_id } = req.body; // 클라이언트에서 상대방 ID 전달
    const u1_id = req.session?.user?.id; // 현재 로그인된 사용자 ID (세션)

    if (!u2_id) {
        return res.status(400).json({ success: false, message: '상대방 ID(u2_id)는 필수입니다.' });
    }

    try {
        // 두 사용자 간의 미션 목록 조회
        const missions = await Mission.findAll({
            where: {
                [Op.or]: [
                    { u1_id, u2_id }, // 현재 사용자가 u1_id
                    { u1_id: u2_id, u2_id: u1_id } // 상대방이 u1_id
                ],
            },
            attributes: ['m_title', 'm_deadline', 'u2_id'], // 필요한 속성만 선택
            order: [['m_deadline', 'ASC']], // 마감일 순서대로 정렬
        });

        if (missions.length === 0) {
            return res.status(404).json({ success: false, message: '해당 방에 미션이 없습니다.' });
        }

        // JSON 응답 반환
        res.status(200).json({
            success: true,
            missions: missions.map(mission => ({
                title: mission.m_title,
                deadline: mission.m_deadline,
                performer: mission.u2_id, // 미션 수행자
            })),
        });
    } catch (error) {
        console.error('미션 조회 오류:', error.message);
        res.status(500).json({ success: false, message: '미션 조회 중 오류가 발생했습니다.', error: error.message });
    }
};


// 마감 기한 확인 및 미션 상태 업데이트 함수
exports.checkMissionDeadline = async () => {
    try {
        // 현재 시간 가져오기
        const now = new Date();

        // 마감 기한이 지난 미션 조회
        const expiredMissions = await Mission.findAll({
            where: {
                m_deadline: {
                    [Op.lt]: now, // 현재 시간보다 이전인 미션만 선택
                },
                m_status: '진행중', // 진행 중 상태인 미션만
            },
        });

        // 각 미션의 상태를 '실패'로 업데이트
        for (const mission of expiredMissions) {
            await mission.update({ m_status: '실패' });
        }

        console.log(`마감 기한이 지난 ${expiredMissions.length}개의 미션 상태를 '실패'로 업데이트했습니다.`);
    } catch (error) {
        console.error('마감 기한 확인 및 상태 업데이트 오류:', error);
    }
};


// 미션 상태 별 리스트 출력

// 상태를 요청으로 변환