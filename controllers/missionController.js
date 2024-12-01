// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기
// const { sequelize } = require('../models/missionModel'); // sequelize 객체 불러오기
const Room = require('../models/roomModel'); // Room 모델 가져오기
const MResult = require('../models/m_resultModel.js'); //MResult 모델 가져오기
const CRoom = require('../models/comunity_roomModel'); // Community Room 테이블
const resultController = require('./resultController'); // resultController 가져오기
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // Sequelize의 연산자 가져오기

// const sequelize = require('../config/db'); // 데이터베이스 연결

// const jwt = require('jsonwebtoken'); // JWT 추가

// 미션 생성 함수
exports.createMission = async (req, res) => {
    const { u1_id, u2_id, m_title, m_deadline, m_reword } = req.body; 
    try {
        // u1_id와 u2_id로 Room 확인 및 r_id 가져오기
        const room = await Room.findOne({
            where: {
                u1_id,
                u2_id
            }
        });

        if (!room) {
            return res.status(400).json({ success: false, message: '방이 존재하지 않습니다.' });
        }

        const missionId = uuidv4();
        let stat = "진행중";

        // 미션 생성
        await Mission.create({
            m_id: missionId,
            u1_id,
            u2_id,
            m_title,
            m_deadline,
            m_reword,
            m_status: stat,
            r_id: room.r_id // Room ID를 저장
        });

        res.status(201).json({ success: true, message: '미션이 생성되었습니다.' });
    } catch (error) {
        console.error('미션 생성 오류:', error);
        res.status(500).json({ success: false, message: '미션 생성 중 오류가 발생했습니다.' });
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

//=====================================================================================
// 자신이 수행해야 할 미션 목록 (u2_id = userId)(방 이름 포함)
exports.getAssignedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const assignedMissions = await Mission.findAll({
            where: {
                u2_id: userId, // 자신이 수행해야 할 미션
                m_status: { [Op.or]: ['진행중', '요청'] }, // "진행중" 또는 "요청"인 미션만 //==========추가==============
            },
            include: [
                {
                    model: Room,
                    as: 'room',
                    attributes: ['r_id', 'r_title'], // 방 이름만 가져오기
                },
            ],
        });

        console.log('[DEBUG] Assigned Missions:', assignedMissions); // 디버깅 로그 추가

        const missions = assignedMissions.map(mission => ({
            m_id: mission.m_id,
            m_title: mission.m_title,
            m_deadline: mission.m_deadline,
            m_status: mission.m_status,
            r_id: mission.r_id,
            r_title: mission.room ? mission.room.r_title : '없음',
        }));

        res.json({ missions });
    } catch (error) {
        console.error('자신이 수행해야 할 미션 조회 오류:', error);
        res.status(500).json({ message: '수행해야 할 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 부여한 미션 목록 (u1_id = userId)(방 이름 포함)
exports.getCreatedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const createdMissions = await Mission.findAll({
            where: {
                u1_id: userId,
                u2_id: {
                    [Op.ne]: userId, // 자신이 자신에게 부여한 미션은 제외
                },
                m_status: { [Op.or]: ['진행중', '요청'] }, // "진행중" 또는 "요청"인 미션만 //==========추가==============
            },

            include: [
                {
                    model: Room,
                    as: 'room',
                    attributes: ['r_id', 'r_title'], // 방 이름만 가져오기
                },
            ],
        });

        const missions = createdMissions.map(mission => ({
            m_id: mission.m_id,
            m_title: mission.m_title,
            m_deadline: mission.m_deadline,
            
            m_status: mission.m_status,
            r_id: mission.r_id,
            r_title: mission.room ? mission.room.r_title : '없음',
        }));

        res.json({ missions });
    } catch (error) {
        console.error('자신이 부여한 미션 조회 오류:', error);
        res.status(500).json({ message: '부여한 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 완료한 미션 목록 //==========추가==============
exports.getCompletedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const completedMissions = await Mission.findAll({
            where: {
                u2_id: userId,
                m_status: '완료', // "완료" 상태의 미션만
            },
        });

        res.json({ missions: completedMissions });
    } catch (error) {
        console.error('Completed missions error:', error);
        res.status(500).json({ message: 'Completed missions fetch failed.' });
    }
};


// 자신이 부여한 미션 중 상대가 완료한 미션 목록 //==========추가==============
exports.getGivenCompletedMissions = async (req, res) => {
    try {
        const userId = req.session.user.id;

        const givenCompletedMissions = await Mission.findAll({
            where: {
                u1_id: userId,
                u2_id: { [Op.ne]: userId }, // 상대방이 수행한 미션만
                m_status: '완료', // "완료" 상태의 미션만
            },
        });

        res.json({ missions: givenCompletedMissions });
    } catch (error) {
        console.error('Given completed missions error:', error);
        res.status(500).json({ message: 'Given completed missions fetch failed.' });
    }
};

//=====================================================================================


// // 자신이 수행해야 할 미션 목록 (u2_id = userId)
// exports.getAssignedMissions = async (req, res) => {
//     try {
//         const userId = req.session.user.id;

//         const assignedMissions = await Mission.findAll({
//             where: { u2_id: userId },
//             include: [
//                 {
//                     model: Room,
//                     as: 'room', // Room 테이블
//                     attributes: ['r_title'],
//                 },
//                 {
//                     model: CRoom,
//                     as: 'communityRoom', // Community Room 테이블
//                     attributes: ['cr_title'],
//                 },
//             ],
//         });

//         const missions = assignedMissions.map((mission) => ({
//             missionTitle: mission.m_title,
//             deadline: mission.m_deadline,
//             status: mission.m_status,
//             roomTitle: mission.room ? mission.room.r_title : null,
//             communityRoomTitle: mission.communityRoom ? mission.communityRoom.cr_title : null,
//         }));

//         res.json({ missions });
//     } catch (error) {
//         console.error('수행해야 할 미션 조회 오류:', error);
//         res.status(500).json({ message: '수행해야 할 미션을 불러오는데 실패했습니다.' });
//     }
// };

// // 자신이 부여한 미션 목록 (u1_id = userId)
// exports.getCreatedMissions = async (req, res) => {
//     try {
//         const userId = req.session.user.id;

//         const createdMissions = await Mission.findAll({
//             where: { u1_id: userId },
//             include: [
//                 {
//                     model: Room,
//                     as: 'room', // Room 테이블
//                     attributes: ['r_title'],
//                 },
//                 {
//                     model: CRoom,
//                     as: 'communityRoom', // Community Room 테이블
//                     attributes: ['cr_title'],
//                 },
//             ],
//         });

//         const missions = createdMissions.map((mission) => ({
//             missionTitle: mission.m_title,
//             deadline: mission.m_deadline,
//             status: mission.m_status,
//             roomTitle: mission.room ? mission.room.r_title : null,
//             communityRoomTitle: mission.communityRoom ? mission.communityRoom.cr_title : null,
//         }));

//         res.json({ missions });
//     } catch (error) {
//         console.error('부여한 미션 조회 오류:', error);
//         res.status(500).json({ message: '부여한 미션을 불러오는데 실패했습니다.' });
//     }
// };


// 방이름 추가 - 유저 아이디/닉네임으로 



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


// 미션 인증 요청 함수
exports.requestMissionApproval = async (req, res) => {
    const { m_id } = req.body; // 클라이언트에서 미션 ID 전달
    const userId = req.session?.user?.id; // 세션에서 로그인된 사용자 ID 가져오기

    try {
        // 미션이 존재하는지 확인
        const mission = await Mission.findOne({ where: { m_id } });

        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        // 미션 상태가 "진행중"인지 확인
        if (mission.m_status !== '진행중') {
            return res.status(400).json({ success: false, message: '현재 상태에서는 미션 요청이 불가능합니다.' });
        }

        // 미션 수행자만 요청 가능하도록 확인
        if (mission.u2_id !== userId) {
            return res.status(403).json({ success: false, message: '미션 수행자만 요청할 수 있습니다.' });
        }

        // 정확히 해당 미션만 상태를 "요청"으로 변경
        const updated = await Mission.update(
            { m_status: '요청' },
            { where: { m_id, u2_id: userId } } // 정확히 조건 추가
        );

        if (updated[0] === 0) {
            return res.status(400).json({ success: false, message: '미션 상태를 변경할 수 없습니다.' });
        }

        res.json({ success: true, message: '미션 상태가 "요청"으로 변경되었습니다.' });
    } catch (error) {
        console.error('미션 요청 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 요청 처리 중 오류가 발생했습니다.' });
    }
};


// 미션 성공 처리 함수
exports.successMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.session.user.id;
    try {
        const mission = await Mission.findOne({ where: { m_id, u1_id } });

        if (!mission) {
            return res.json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }
        
        // m_status가 "요청"일 때만 상태 변경 가능
        if (mission.m_status !== '요청') {
            return res.status(400).json({ success: false, message: '현재 상태에서는 미션을 성공으로 변경할 수 없습니다.' });
        }

        // m_status를 "완료"로 업데이트
        await Mission.update(
            { m_status: '완료' },
            { where: { m_id, u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
        );

        // 현재 시간 저장
        const currentTime = new Date();

        // resultController를 통해 결과 저장
        const saveResultResponse = await resultController.saveResult(
            m_id,
            u1_id,
            // mission.m_deadline,
            currentTime, // 현재 시간 전달
            '성공'
        );

        // saveResultResponse가 성공하지 않은 경우
        if (!saveResultResponse.success) {
            return res.status(500).json({
                success: false,
                message: `결과 저장 중 오류가 발생했습니다. controller: ${saveResultResponse.error || '알 수 없는 오류'}`,
                error: saveResultResponse.error || '알 수 없는 오류',
            });
        }

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

        // m_status가 "요청"일 때만 상태 변경 가능
        if (mission.m_status !== '요청') {
            return res.json({ success: false, message: '현재 상태에서는 미션을 성공으로 변경할 수 없습니다.' });
        }

        await Mission.update(
            { m_status: '완료' },
            { where: { m_id, u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
        );

        // 현재 시간 저장
        const currentTime = new Date();

        // resultController를 통해 결과 저장
        const saveResultResponse = await resultController.saveResult(
            m_id,
            u1_id,
            // mission.m_deadline,
            currentTime, // 현재 시간 전달
            '실패'
        );

        // saveResultResponse가 성공하지 않은 경우
        if (!saveResultResponse.success) {
            return res.status(500).json({
                success: false,
                message: `결과 저장 중 오류가 발생했습니다. controller: ${saveResultResponse.error || '알 수 없는 오류'}`,
                error: saveResultResponse.error || '알 수 없는 오류',
            });
        }

        // saveResultResponse가 성공하지 않은 경우
        if (!saveResultResponse.success) {
            return res.status(500).json({
                success: false,
                message: `결과 저장 중 오류가 발생했습니다.`,
                error: saveResultResponse.error || '알 수 없는 오류',
            });
        }

        res.json({ success: true, message: '미션이 실패로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 실패 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 인증 실패 처리 중 오류가 발생했습니다.' });
    }
};

//방미션출력
exports.printRoomMission = async (req, res) => {
    const { r_id } = req.body;
    const { u2_id } = req.body; // 클라이언트에서 상대방 ID 전달
    const u1_id = req.session?.user?.id; // 현재 로그인된 사용자 ID (세션)

    if (!r_id) {
        return res.status(400).json({ success: false, message: '방 ID(r_id)는 필수입니다.' });
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
                m_deadline: { [Op.lte]: now }, // 마감 기한이 현재 시간과 같거나 이전
                m_status: { [Op.or]: ['진행중', '요청'] }, // 상태가 "진행중" 또는 "요청"
            },
        });

        // // 각 미션의 상태를 '실패'로 업데이트
        // for (const mission of expiredMissions) {
        //     await mission.update({ m_status: '실패' });
        // }

        // 각 미션의 상태를 확인하여 조건에 따라 처리
        for (const mission of expiredMissions) {
            const deadline = new Date(mission.m_deadline); // 마감 기한 가져오기
            const originalDeadline = new Date(deadline); // 원래 마감 기한 저장
            const extendedDeadline = new Date(deadline.getTime() + 10 * 60 * 1000); // 10분 추가된 기한

            if (mission.m_extended === true) {
                // 1. m_extended === true
                await mission.update({
                    m_status: '완료',
                    m_deadline: new Date(deadline.getTime() - 10 * 60 * 1000), // 마감 기한을 10분 줄임
                });

                await MResult.create({
                    m_id: mission.m_id,
                    u_id: mission.u2_id,
                    m_deadline: originalDeadline, // 원래 마감 기한 저장
                    m_status: '실패',
                });

                console.log(
                    `미션 ${mission.m_id}이 완료 처리되고, m_result에 저장되었습니다.`
                );
            } else if (
                deadline.getDate() !== extendedDeadline.getDate() ||
                deadline.getMonth() !== extendedDeadline.getMonth() ||
                deadline.getFullYear() !== extendedDeadline.getFullYear()
            ) {
                // 2. 날짜가 변함
                await mission.update({ m_status: '완료' });

                await MResult.create({
                    m_id: mission.m_id,
                    u_id: mission.u2_id,
                    m_deadline: originalDeadline, // 원래 마감 기한 저장
                    m_status: '실패',
                });

                console.log(
                    `미션 ${mission.m_id}의 마감 기한이 지났고 날짜가 변경되었으므로 완료 처리되었습니다.`
                );
            } else {
                // 3. 날짜가 변하지 않음
                await mission.update({
                    m_deadline: extendedDeadline, // 마감 기한을 10분 연장
                    m_extended: true, // 추가 시간 플래그를 true로 설정
                });

                console.log(
                    `미션 ${mission.m_id}의 마감 기한이 10분 연장되었습니다.`
                );
            }

        }
        // console.log(`마감 기한이 지난 ${expiredMissions.length}개의 미션 상태를 '실패'로 업데이트했습니다.`);
        console.log(`총 ${expiredMissions.length}개의 미션을 처리했습니다.`);
    } catch (error) {
        console.error('마감 기한 확인 및 상태 업데이트 오류:', error);
    }
};


// 미션 상태 별 리스트 출력

// 상태를 요청으로 변환