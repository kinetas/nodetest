const CRoom = require('../models/comunity_roomModel'); // comunity_room 모델 가져오기
const Room = require('../models/roomModel'); // room 모델
const Mission = require('../models/missionModel'); // mission 모델
const MResult = require('../models/m_resultModel');
const User = require('../models/userModel');
const notificationController = require('../controllers/notificationController'); // notificationController 가져오기
const Sequelize = require('sequelize');
const { sequelize } = require('../models/comunity_roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // [추가됨]

// 첫 번째 조건: 커뮤니티 미션 생성
exports.createCommunityMission = async (req, res) => {
    // const { cr_title } = req.body; // 제목 입력 받기
    const { cr_title, contents, deadline } = req.body;
    const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
    const cr_num = uuidv4(); // 랜덤 값 생성
    const cr_status = "match";
    const m1_status = "0";
    const m2_status = "0";

    try {
        // await CRoom.create({ u_id, cr_num, cr_title, cr_status, m1_status, m2_status });
        await CRoom.create({ u_id, cr_num, cr_title, cr_status, m1_status, m2_status, contents, deadline });
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
        // const room = await Room.findOne({ where: { u1_id, u2_id } });
        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.u_id === u2_id) {
            return res.status(403).json({ success: false, message: '본인이 생성한 미션은 수락할 수 없습니다.' });
        }
        if(mission.cr_status == 'acc'){
            return res.status(403).json({ success: false, message: '이미 수락된 미션입니다.' });
        }

        // [추가됨] 방 존재 여부 확인
        const rooms = await Room.findAll({
            where: {
                r_type: 'open', // 방 타입 조건
                [Op.or]: [
                    { u1_id: mission.u_id, u2_id }, // 첫 번째 조합
                    { u1_id: u2_id, u2_id: mission.u_id } // 반대 조합
                ]
            }
        });

        let rid_u1_u2 = uuidv4();
        let rid_u2_u1 = uuidv4();
        let rid_open = uuidv4();

        if (rooms.length === 0) {
            // [추가됨] 방 생성
            roomId = uuidv4();
            await Room.create({ 
                u1_id: mission.u_id, 
                u2_id, 
                // r_id: rid_u1_u2, 
                r_id: rid_open,
                r_title: `${mission.u_id}-${u2_id}`, 
                r_type: 'open' 
            });

            await Room.create({ 
                u1_id: u2_id, 
                u2_id: mission.u_id, 
                // r_id: rid_u2_u1, 
                r_id: rid_open,
                r_title: `${u2_id}-${mission.u_id}`, 
                r_type: 'open' 
            });
        } else {
            // [변경됨] 기존 방 ID 사용
            // rid_u1_u2 = rooms.find(r => r.u1_id === mission.u_id && r.u2_id === u2_id)?.r_id || uuidv4();
            // rid_u2_u1 = rooms.find(r => r.u1_id === u2_id && r.u2_id === mission.u_id)?.r_id || uuidv4();
            rid_open = rooms.find(r => r.u1_id === u2_id && r.u2_id === mission.u_id)?.r_id || uuidv4();
        }

        // 커뮤니티 미션 업데이트
        await mission.update({ u2_id, cr_status: 'acc' });


        // // Room 테이블에 데이터 생성
        // await Room.create({ 
        //     u1_id: mission.u_id, 
        //     u2_id, 
        //     r_id: rid_u1_u2, 
        //     r_title: `${mission.u_id}-${u2_id}`, 
        //     r_type: 'open' 
        // });

        // // 반대 Room 테이블에 데이터 생성
        // await Room.create({ 
        //     u1_id: u2_id, 
        //     u2_id: mission.u_id, 
        //     r_id: rid_u2_u1, 
        //     r_title: `${u2_id}-${mission.u_id}`, 
        //     r_type: 'open' 
        // });

        // Mission 테이블에 미션 생성
        const newMissionId1 = uuidv4();
        const newMissionId2 = uuidv4();
        const missionTitle = mission.cr_title;

        const currentDate = new Date();
        // const deadline = new Date(currentDate.setDate(currentDate.getDate() + 3));
        const deadline = mission.deadline ? mission.deadline : new Date(currentDate.setDate(currentDate.getDate() + 3));

        await Mission.create({
            m_id: newMissionId1,
            u1_id: mission.u_id,
            u2_id,
            m_title: missionTitle,
            m_deadline: deadline,
            m_reword: null,
            m_status: '진행중',
            // r_id: rid_u1_u2,
            r_id: rid_open,
            m_extended: false,
            missionAuthenticationAuthority: mission.u_id,
        });

        await Mission.create({
            m_id: newMissionId2,
            u1_id: u2_id,
            u2_id: mission.u_id,
            m_title: missionTitle,
            m_deadline: deadline,
            m_reword: null,
            m_status: '진행중',
            // r_id: rid_u2_u1,
            r_id: rid_open,
            m_extended: false,
            missionAuthenticationAuthority: u2_id,
        });

        // ================ 알림 추가 - 디바이스 토큰 =======================
        
        const sendAcceptCommunityMissionNotification = await notificationController.sendAcceptCommunityMissionNotification(
            mission.u_id,
            missionTitle
        );

        if(!sendAcceptCommunityMissionNotification){
            return res.status(400).json({ success: false, message: '커뮤니티 미션 수락 알림 전송을 실패했습니다.' });
        }
        
        // ================ 알림 추가 - 디바이스 토큰 =======================

        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 수락되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 수락 오류:', error);
        res.status(500).json({ success: false, message: `커뮤니티 미션 수락 중 오류(${error})가 발생했습니다.` });
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
exports.checkMissionStatus = async () => {
    try {
        // 진행 중인 커뮤니티 미션 조회
        const missions = await CRoom.findAll({
            where: {
                cr_status: 'acc',
                [Sequelize.Op.or]: [
                    { m1_status: 0 },
                    { m2_status: 0 }
                ]
            }
        });

        for (const mission of missions) {
        //     // 만든 사람의 미션 상태 확인
        //     const creatorMission = await Mission.findOne({
        //         where: { u1_id: mission.u_id, u2_id:mission.u2_id }
        //     });
        //     if (creatorMission.m_status === '성공' || creatorMission.m_status === '실패') {
        //         await mission.update({ m1_status: 1 });
        //     }

        //     // 수락한 사람의 미션 상태 확인
        //     const accepterMission = await Mission.findOne({
        //         where: { u1_id: mission.u2_id, u2_id:mission.u_id }
        //     });
        //     if (accepterMission.m_status === '성공' || accepterMission.m_status === '실패') {
        //         await mission.update({ m2_status: 1 });
        //     }

        //     // m1_status와 m2_status가 모두 1이면 처리
        //     if (mission.m1_status === 1 && mission.m2_status === 1) {
        //         // 관련 데이터 삭제
        //         await Room.destroy({ where: { u1_id: mission.u2_id, u2_id:mission.u_id } });
        //         await Room.destroy({ where: { u1_id: mission.u_id, u2_id:mission.u2_id } });
        //         await CRoom.destroy({ where: { cr_num: mission.cr_num } });

        //         // 결과 기록
        //         await MResult.create({
        //             m_id: mission.cr_num,
        //             u_id: mission.u_id,
        //             m_deadline: new Date(),
        //             m_status: creatorMission.m_status === '성공' && accepterMission.m_status === '성공' ? '성공' : '실패'
        //         });
        //     }
        // }
            
            // [변경됨] 만든 사람의 모든 미션 상태 확인
            const creatorMissions = await Mission.findAll({
                where: {
                    u1_id: mission.u_id, // Mission 테이블의 u1_id = community_room의 u_id
                    u2_id: mission.u2_id, // Mission 테이블의 u2_id = community_room의 u2_id
                }
            });
            const allCreatorMissionsCompleted = creatorMissions.every(
                (m) => m.m_status === '완료'
            );

            if (allCreatorMissionsCompleted) {
                await mission.update({ m1_status: 1 });
            }

            // [변경됨] 수락한 사람의 모든 미션 상태 확인
            const accepterMissions = await Mission.findAll({
                where: { 
                    u1_id: mission.u2_id, 
                    u2_id: mission.u_id,
                    // r_id: r_id2,    
                }
            });
            const allAccepterMissionsCompleted = accepterMissions.every(
                (m) => m.m_status === '완료'
            );

            if (allAccepterMissionsCompleted) {
                await mission.update({ m2_status: 1 });
            }

            // const getRidAtRoom = await Room.findOne({
            //     where: {
            //         u1_id: mission.u_id,
            //         u2_id: mission.u2_id,
            //         r_type: "open",
            //     },
            // });
            
            // const r_id = getRidAtRoom ? getRidAtRoom.r_id : null;
            
            // const getRidAtRoom2 = await Room.findOne({
            //     where: {
            //         u1_id: mission.u2_id,
            //         u2_id: mission.u_id,
            //         r_type: "open",
            //     },
            // });
            
            // const r_id2 = getRidAtRoom2 ? getRidAtRoom2.r_id : null;


            // // [유지됨] m1_status와 m2_status가 모두 1이면 데이터 삭제
            // if (mission.m1_status === 1 && mission.m2_status === 1) {
            //     // 관련 데이터 삭제
            //     if (r_id && r_id2) {
            //         await Mission.destroy({ where: { u1_id: mission.u2_id, u2_id: mission.u_id, r_id: r_id2 } });
            //         await Mission.destroy({ where: { u1_id: mission.u_id, u2_id: mission.u2_id, r_id: r_id } });
                    
            //         await Room.destroy({ where: { u1_id: mission.u2_id, u2_id: mission.u_id } });
            //         await Room.destroy({ where: { u1_id: mission.u_id, u2_id: mission.u2_id } });
            //         await CRoom.destroy({ where: { cr_num: mission.cr_num } });
            //     }
            // }

            // [추가됨] 같은 사용자 간 여러 커뮤니티 방 상태 확인
            const relatedRooms = await CRoom.findAll({
                where: {
                    [Op.or]: [
                        { u_id: mission.u_id, u2_id: mission.u2_id },
                        { u_id: mission.u2_id, u2_id: mission.u_id }
                    ],
                    cr_status: 'acc'
                }
            });

            const allRoomsCompleted = relatedRooms.every(
                (room) => room.m1_status === '1' && room.m2_status === '1'
            );

            if (allRoomsCompleted) {
                // 관련 데이터 삭제
                for (const room of relatedRooms) {
                    const getRidAtRoom = await Room.findOne({
                        where: {
                            u1_id: room.u_id,
                            u2_id: room.u2_id,
                            r_type: "open",
                        },
                    });

                    const r_id = getRidAtRoom ? getRidAtRoom.r_id : null;

                    const getRidAtRoom2 = await Room.findOne({
                        where: {
                            u1_id: room.u2_id,
                            u2_id: room.u_id,
                            r_type: "open",
                        },
                    });

                    const r_id2 = getRidAtRoom2 ? getRidAtRoom2.r_id : null;

                    if (r_id && r_id2) {
                        await Mission.destroy({ where: { u1_id: room.u2_id, u2_id: room.u_id, r_id: r_id2 } });
                        await Mission.destroy({ where: { u1_id: room.u_id, u2_id: room.u2_id, r_id: r_id } });

                        await Room.destroy({ where: { u1_id: room.u2_id, u2_id: room.u_id } });
                        await Room.destroy({ where: { u1_id: room.u_id, u2_id: room.u2_id } });
                        // await CRoom.destroy({ where: { cr_num: room.cr_num } });
                        await CRoom.destroy({ where: { u_id: room.u2_id, u2_id: room.u_id } });
                        await CRoom.destroy({ where: { u_id: room.u_id, u2_id: room.u2_id } });
                    }
                }
            }
        }
    } catch (error) {
        console.error('미션 상태 감지 및 처리 오류:', error);
    }
};