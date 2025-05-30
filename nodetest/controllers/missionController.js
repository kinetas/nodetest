// controllers/missionController.js
const Mission = require('../models/missionModel'); // Mission 모델 불러오기
const Room = require('../models/roomModel'); // Room 모델 가져오기
const CRoom = require('../models/comunity_roomModel');
const MResult = require('../models/m_resultModel.js'); //MResult 모델 가져오기
const IFriend = require('../models/i_friendModel'); // 친구 관계 모델 추가
const CVote = require('../models/comunity_voteModel');
const resultController = require('../controllers/resultController'); // resultController 가져오기
const roomController = require('../controllers/roomController');
const notificationController = require('../controllers/notificationController'); // notificationController 가져오기
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // Sequelize의 연산자 가져오기

const leagueController = require('../controllers/leagueController');

// 미션 완료 시 커뮤니티 미션인지 확인 후 커뮤니티 방에 미션 상태 업데이트
async function updateCommunityRoomStatusOnMissionComplete(mission) {
    try {
      console.log("🔍 mission.r_id:", mission.r_id);
      // 1. 해당 미션이 커뮤니티 미션인지 확인 (room.r_type == 'open')
      const relatedRoom = await Room.findOne({
        where: {
          r_id: mission.r_id,
          r_type: 'open'
        }
      });
  
      if (!relatedRoom) {
        console.log("❌ 해당 r_id를 가진 open room이 없습니다.");
        return; // 커뮤니티 미션이 아니면 종료
      }
  
      // 2. 해당 미션과 매칭되는 community_room 찾기 (m1_id 또는 m2_id)
      const cRoom = await CRoom.findOne({
        where: {
          [Op.or]: [
            { m1_id: mission.m_id },
            { m2_id: mission.m_id }
          ]
        }
      });
  
      if (!cRoom) return;
  
      // 3. 문자열로 비교 (형 변환)
      const mId = mission.m_id.toString();
  
      if (cRoom.m1_id && cRoom.m1_id.trim() === mission.m_id.trim()) {
        await CRoom.update(
          { m1_status: mission.m_status },
          { where: { cr_num: cRoom.cr_num } }
        );
        console.log(`✅ cr_num ${cRoom.cr_num} - m1_status 업데이트 완료`);
      } else if (cRoom.m2_id && cRoom.m2_id.trim() === mission.m_id.trim()) {
        await CRoom.update(
          { m2_status: mission.m_status },
          { where: { cr_num: cRoom.cr_num } }
        );
        console.log(`✅ cr_num ${cRoom.cr_num} - m2_status 업데이트 완료`);
      } else {
        console.log(`⚠️ mission.m_id와 일치하는 m1_id/m2_id가 없습니다`);
      }
  
    } catch (err) {
      console.error('❌ 커뮤니티 미션 상태 업데이트 중 오류:', err);
    }
  }

// 미션 생성 함수
exports.createMission = async (req, res) => {
    const { u2_id, authenticationAuthority, m_title, m_deadline, m_reword, category } = req.body;
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {

        // 마감기한이 입력되지 않은 경우 에러 반환
        if (!m_deadline) {
            return res.status(400).json({
                success: false,
                message: '미션 마감기한을 입력해야 합니다.',
            });
        }

        // 마감기한이 과거인 경우 에러 반환
        const now = new Date();
        if (new Date(m_deadline) < now) {
            return res.status(400).json({
                success: false,
                message: '미션 마감기한은 현재 시간보다 이후여야 합니다.',
            });
        }

        const assignedU2Id = u2_id || u1_id;

        // 1. 자신에게 미션 생성 시
        if (assignedU2Id === u1_id) {
            const missionAuthenticationAuthority = authenticationAuthority || u1_id;
            console.log("missionAuthenticationAuthority(missionController.js:58): ", missionAuthenticationAuthority)
            // 1-1. 인증권한자가 미션생성자가 아닌 경우 (= 인증권한을 친구에게 맡기는 경우)
            if (missionAuthenticationAuthority !== u1_id) {
                console.log("1-1 경우");
                const isFriend = await IFriend.findOne({
                    where: { u_id: u1_id, f_id: missionAuthenticationAuthority },
                });

                //1-1-1. 입력한 인증권한자가 친구가 아니면 에러메시지 반환
                if (!isFriend) {
                    console.log("1-1-1 경우");
                    return res.status(400).json({
                        success: false,
                        message: '인증 권한자로 선택된 사용자가 친구 목록에 없습니다.',
                    });
                }

                //1-1-2. 입력한 인증권한자가 친구일때 
                console.log("1-1-2 경우");
                //인증권한자인 친구와의 방 여부 확인
                let room = await Room.findOne({
                    where: {
                        u1_id: assignedU2Id,
                        u2_id: missionAuthenticationAuthority,
                        r_type: 'general',
                    }
                });

                //1-1-2-1. 인증권한자인 친구와의 방이 없다면 방 생성
                if (!room){
                    console.log("1-1-2-1 경우");
                    console.log("assignedU2Id: ", assignedU2Id);
                    console.log("missionAuthenticationAuthority: ", missionAuthenticationAuthority);
                    const fakeReq = { 
                        body: {
                            u2_id: missionAuthenticationAuthority,
                            roomName: `${assignedU2Id}-${missionAuthenticationAuthority}`,
                            r_type: 'general'
                        },
                        currentUserId: assignedU2Id
                     };
                    const fakeRes = {
                        status: () => ({ json: (data) => data }),
                        json: (data) => data
                    };
                    const result = await roomController.addRoom(fakeReq, fakeRes);
                    console.log("result: ", result);
                    room = await Room.findOne({
                        where: {
                            u1_id: assignedU2Id,
                            u2_id: missionAuthenticationAuthority
                        }
                    });
                    console.log("room: ", room);
                    if (!room || !room.r_id) {
                        return res.status(500).json({ message: '방 조회 실패 (room 없거나 r_id 없음) (missionController.js:158)' });
                    }
                }

                //1-1-2. 미션 생성
                console.log("1-1-2 미션생성");
                await Mission.create({
                    m_id: uuidv4(),
                    u1_id,
                    u2_id: assignedU2Id,    // 입력받은 u2_id 또는 u1_id를 저장
                    m_title,
                    m_deadline,
                    m_reword,
                    m_status: '진행중',
                    r_id: room.r_id, // Room ID를 저장
                    m_extended: false,
                    missionAuthenticationAuthority,
                    category,
                });

                // ================ 알림 추가 - 디바이스 토큰 =======================
            
                const sendMissionCreateAuthenticationNotification = await notificationController.sendMissionCreateAuthenticationNotification(
                    u1_id,
                    missionAuthenticationAuthority,
                );

                if(!sendMissionCreateAuthenticationNotification){
                    return res.status(400).json({ success: false, message: '미션 생성 알림 전송을 실패했습니다.' });
                }
                // ================ 알림 추가 - 디바이스 토큰 =======================

                return res.status(201).json({ success: true, message: '미션이 생성되었습니다.' });
            }
            //1-2. 인증권한자가 미션생성자인 경우
            console.log("1-2 경우");
            //u1_id와 u2_id로 Room 확인 및 r_id 가져오기 (자신의 방 존재 여부 확인)
            let room = await Room.findOne({
                where: {
                    u1_id,
                    u2_id: assignedU2Id // = u1_id
                }
            });

            //1-2-1. 자신의 방이 없다면 방 생성 (initAddRoom)
            if (!room) {
                console.log("1-2-1 경우");
                const initRoomRes = await roomController.initAddRoom({
                    body: { u1_id, roomName: `${u1_id}-${u1_id}` }
                });
                console.log("initRoomRes(missionController.js:147): ", initRoomRes);
                if (!initRoomRes || !initRoomRes.success) {
                    return res.status(500).json({ success: false, message: '자신의 방 생성 실패' });
                }
                room = await Room.findOne({
                    where: {
                        u1_id,
                        u2_id: assignedU2Id // = u1_id
                    }
                });
                if (!room || !room.r_id) {
                    return res.status(500).json({ message: '방 조회 실패 (room 없거나 r_id 없음) (missionController.js:158)' });
                }
                console.log("room(missionController.js:160): ", room);
            }

            const missionId = uuidv4();
            let stat = "진행중";

            //1-2. 미션 생성
            console.log("1-2 미션생성");
            await Mission.create({
                m_id: missionId,
                u1_id,
                u2_id: assignedU2Id,    // 입력받은 u2_id 또는 u1_id를 저장
                m_title,
                m_deadline,
                m_reword,
                m_status: stat,
                r_id: room.r_id, // Room ID를 저장
                m_extended: false,
                missionAuthenticationAuthority: u1_id,
                category,
            });

            res.status(201).json({ success: true, message: '미션이 생성되었습니다.' });
        } else {
            //2. 타인에게 미션 생성 시
            //2-1. 인증권한자는 자신(u1_id = 미션 생성자 = 미션 부여자)이어야 함
            console.log("2-1 경우");
            if (authenticationAuthority && authenticationAuthority !== u1_id) {
                return res.status(400).json({
                    success: false,
                    message: '다른 사용자에게 미션 생성 시 인증 권한자를 입력할 수 없습니다.',
                });
            }

            //2-2. u2_id가 친구인지 확인
            console.log("2-2 경우");
            const isFriend = await IFriend.findOne({
                where: { u_id: u1_id, f_id: u2_id },
            });
            //2-2-1. u2_id가 친구가 아니라면
            if (!isFriend) {
                console.log("2-2-1 경우");
                return res.status(400).json({
                    success: false,
                    message: '친구가 아닙니다.',
                });
            }

            //2-2-2. u2_id가 친구일 때
            console.log("2-2-2 경우");
            //u1_id와 u2_id로 Room 확인 및 r_id 가져오기
            let room = await Room.findOne({
                where: {
                    u1_id,
                    u2_id: assignedU2Id,
                    r_type: 'general',
                }
            });

            //2-2-2-1. 친구와의 방이 없다면 방 생성 (addRoom)
            if (!room) {
                console.log("2-2-2-1 경우");
                const fakeReq = { 
                    body: {
                        u2_id,
                        roomName: `${u1_id}-${u2_id}`,
                        r_type: 'general'
                    },
                    currentUserId: u1_id
                 };
                const fakeRes = {
                    status: () => ({ json: (data) => data }),
                    json: (data) => data
                };
                const result = await roomController.addRoom(fakeReq, fakeRes);
                console.log("result: ", result);
                room = await Room.findOne({
                    where: {
                        u1_id: u1_id,
                        u2_id: u2_id
                    }
                });
                console.log("room: ", room);
                if (!room || !room.r_id) {
                    return res.status(500).json({ message: '방 조회 실패 (room 없거나 r_id 없음) (missionController.js:158)' });
                }
            }

            const missionId = uuidv4();
            let stat = "진행중";

            //2-2-2. 미션 생성
            console.log("2-2-2 미션생성");
            await Mission.create({
                m_id: missionId,
                u1_id,
                u2_id: assignedU2Id,    // 입력받은 u2_id 또는 u1_id를 저장
                m_title,
                m_deadline,
                m_reword,
                m_status: stat,
                r_id: room?.r_id || null, // Room ID를 저장
                m_extended: false,
                missionAuthenticationAuthority: u1_id,
                category,
            });

            // ================ 알림 추가 - 디바이스 토큰 =======================
            
            const sendMissionCreateNotification = await notificationController.sendMissionCreateNotification(
                u1_id,
                assignedU2Id,
            );

            if(!sendMissionCreateNotification){
                return res.status(400).json({ success: false, message: '미션 생성 알림 전송을 실패했습니다.' });
            }
            // ================ 알림 추가 - 디바이스 토큰 =======================

            res.status(201).json({ success: true, message: '미션이 생성되었습니다.' });
        }
        
    } catch (error) {
        console.error('미션 생성 오류(missionController.js:264):', error);
        res.status(500).json({ success: false, message: `미션 생성 중 오류(${error})가 발생했습니다.` });
    }
};

// 미션 삭제
exports.deleteMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {
        const mission = await Mission.findOne({ where: { m_id } }); // ✅ m_id 기준으로 조회

        if (!mission) {
            return res.status(404).json({ message: '미션을 찾을 수 없습니다.' });
        }

        if (mission.u2_id !== u1_id) {
            return res.status(403).json({ success: false, message: '미션 삭제 권한이 없습니다.' });
        }

        if (mission.m_status !== '진행중') {
            return res.status(403).json({ success: false, message: '완료된 미션은 삭제할 수 없습니다.' });
        }

        await mission.destroy();
        res.json({ message: '미션이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        console.error('미션 삭제 오류:', error);
        res.status(500).json({ message: '미션 삭제 중 오류가 발생했습니다.' });
    }
};

// 미션 리스트 조회 함수
exports.getUserMissions = async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용
        
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
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

        // 1. 자신이 수행해야 할 미션 가져오기
        const assignedMissions = await Mission.findAll({
            where: {
                u2_id: userId, // 자신이 수행해야 할 미션
                m_status: { [Op.or]: ['진행중', '요청'] }, // "진행중" 또는 "요청"인 미션만
            },
        });

        // 2. 각 미션에 대해 Room 테이블에서 r_title 가져오기
        const missionsWithRoomTitle = await Promise.all(
            assignedMissions.map(async (mission) => {
                const room = await Room.findOne({
                    where: { r_id: mission.r_id },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    // m_deadline: moment(mission.m_deadline).tz('Asia/Seoul').format('YYYY-MM-DD HH:mm:ss'),
                    m_status: mission.m_status,
                    r_id: mission.r_id,
                    r_title: room ? room.r_title : '없음',
                    u1_id: mission.u1_id,
                    u2_id: mission.u2_id,
                    missionAuthenticationAuthority: mission.missionAuthenticationAuthority
                };
            })
        );

        res.json({ missions: missionsWithRoomTitle });
    } catch (error) {
        console.error('자신이 수행해야 할 미션 조회 오류:', error);
        res.status(500).json({ message: '수행해야 할 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 부여한 미션 목록 (u1_id = userId)(방 이름 포함)
exports.getCreatedMissions = async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

        // 1. 자신이 부여한 미션 가져오기
        const createdMissions = await Mission.findAll({
            where: {
                u1_id: userId, // 미션을 부여한 사용자
                u2_id: { [Op.ne]: userId }, // 자신에게 부여한 미션은 제외
                m_status: { [Op.or]: ['진행중', '요청'] }, // "진행중" 또는 "요청"인 미션만
            },
        });

        // 2. 각 미션에 대해 Room 테이블에서 r_title 가져오기
        const missionsWithRoomTitle = await Promise.all(
            createdMissions.map(async (mission) => {
                const room = await Room.findOne({
                    where: { r_id: mission.r_id },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    m_status: mission.m_status,
                    r_id: mission.r_id,
                    r_title: room ? room.r_title : '없음',
                    u1_id: mission.u1_id,
                    u2_id: mission.u2_id,
                };
            })
        );

        // 3. 결과 응답
        res.json({ missions: missionsWithRoomTitle });
    } catch (error) {
        console.error('자신이 부여한 미션 조회 오류:', error);
        res.status(500).json({ message: '부여한 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 부여한 미션 목록 / 요청 (u1_id = userId)(방 이름 포함)
exports.getCreatedMissionsReq = async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

        // 1. 자신이 부여한 미션 가져오기
        const createdMissions = await Mission.findAll({
            where: {
                u1_id: userId, // 미션을 부여한 사용자
                u2_id: { [Op.ne]: userId }, // 자신에게 부여한 미션은 제외
                m_status: { [Op.or]: ['요청'] }, // "요청"인 미션만
            },
        });

        // 2. 각 미션에 대해 Room 테이블에서 r_title 가져오기
        const missionsWithRoomTitle = await Promise.all(
            createdMissions.map(async (mission) => {
                const room = await Room.findOne({
                    where: { r_id: mission.r_id },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    m_status: mission.m_status,
                    r_id: mission.r_id,
                    r_title: room ? room.r_title : '없음',
                    u1_id: mission.u1_id,
                    u2_id: mission.u2_id,
                };
            })
        );

        // 3. 결과 응답
        res.json({ missions: missionsWithRoomTitle });
    } catch (error) {
        console.error('자신이 부여한 미션 조회 오류:', error);
        res.status(500).json({ message: '부여한 미션을 불러오는데 실패했습니다.' });
    }
};

// 자신이 완료한 미션 목록 
exports.getCompletedMissions = async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

        // 1. 완료한 미션 가져오기
        const completedMissions = await Mission.findAll({
            where: {
                u2_id: userId,
                m_status: '완료',
            },
        });

        // 2. 각 미션에 대해 m_result 테이블에서 m_status 가져오기
        const missionsWithStatus = await Promise.all(
            completedMissions.map(async (mission) => {
                const result = await MResult.findOne({
                    where: { m_id: mission.m_id, u_id: userId },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    m_status: result ? result.m_status : '정보 없음', // m_result의 m_status 값
                    mission_result_image: result?.mission_result_image || null,
                };
            })
        );

        res.json({ missions: missionsWithStatus });
    } catch (error) {
        console.error('Completed missions error:', error);
        res.status(500).json({ message: 'Completed missions fetch failed.' });
    }
};


// 자신이 부여한 미션 중 상대가 완료한 미션 목록 
exports.getGivenCompletedMissions = async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

        // 1. 부여한 완료된 미션 가져오기
        const givenCompletedMissions = await Mission.findAll({
            where: {
                u1_id: userId,
                m_status: '완료',
                // ✅ u1_id !== u2_id 조건 추가 (Sequelize 방식)
                [Op.not]: {
                    u2_id: userId
                }
            },
        });

        // 2. 각 미션에 대해 m_result 테이블에서 m_status 가져오기
        const missionsWithStatus = await Promise.all(
            givenCompletedMissions.map(async (mission) => {
                const result = await MResult.findOne({
                    where: { m_id: mission.m_id, u_id: mission.u2_id },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    m_status: result ? result.m_status : '정보 없음', // m_result의 m_status 값
                    mission_result_image: result?.mission_result_image || null,
                };
            })
        );

        res.json({ missions: missionsWithStatus });
    } catch (error) {
        console.error('Given completed missions error:', error);
        res.status(500).json({ message: 'Given completed missions fetch failed.' });
    }
};

// ====== 1. 친구가 수행해야 하는 미션 ======
exports.getFriendAssignedMissions = async (req, res) => {
    const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {
        // 1. 로그인한 사용자의 친구 목록 조회
        const friends = await IFriend.findAll({ where: { u_id: userId } });
        const friendIds = friends.map(friend => friend.f_id);

        if (friendIds.length === 0) {
            return res.status(200).json({ missions: [] });
        }

        // 2. 친구가 수행해야 하는 미션 조회
        const missions = await Mission.findAll({
            where: {
                u2_id: { [Op.in]: friendIds },
                // u1_id: { [Op.eq]: userId }, // 로그인한 사용자가 생성한 미션
                m_status: '진행중', // 상태가 '진행중'인 미션
            },
        });

        res.status(200).json({ missions });
    } catch (error) {
        console.error('친구가 수행해야 하는 미션 조회 오류:', error);
        res.status(500).json({ message: '친구가 수행해야 하는 미션을 조회하는 중 오류가 발생했습니다.' });
    }
};

// ====== 2. 친구가 완료한 미션 ======
exports.getFriendCompletedMissions = async (req, res) => {
    const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {
        // 1. 로그인한 사용자의 친구 목록 조회
        const friends = await IFriend.findAll({ where: { u_id: userId } });
        const friendIds = friends.map(friend => friend.f_id);

        if (friendIds.length === 0) {
            return res.status(200).json({ missions: [] });
        }

        // 2. 친구가 완료한 미션 조회
        const missions = await Mission.findAll({
            where: {
                u2_id: { [Op.in]: friendIds },
                m_status: '완료', // 상태가 '완료'인 미션
            },
        });

        // 3. 각 미션에 대해 m_result 테이블에서 m_status, image 가져오기
        const missionsWithStatus = await Promise.all(
            missions.map(async (mission) => {
                const result = await MResult.findOne({
                    where: { m_id: mission.m_id, u_id: mission.u2_id },
                });

                return {
                    m_id: mission.m_id,
                    m_title: mission.m_title,
                    m_deadline: mission.m_deadline,
                    u_id: mission.u2_id,
                    m_status: result ? result.m_status : '정보 없음', // m_result의 m_status 값
                    mission_result_image: result?.mission_result_image || null,
                };
            })
        );

        res.status(200).json({ missions: missionsWithStatus });
    } catch (error) {
        console.error('친구가 완료한 미션 조회 오류:', error);
        res.status(500).json({ message: '친구가 완료한 미션을 조회하는 중 오류가 발생했습니다.' });
    }
};

// ======= 3. 인증 권한을 부여한 미션 조회 =======
exports.getMissionsWithGrantedAuthority = async (req, res) => {
    const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {
        // 로그인한 사용자가 인증 권한을 부여한 미션 조회
        const missions = await Mission.findAll({
            where: { missionAuthenticationAuthority: { [Op.ne]: userId }, u1_id: userId },
        });

        res.status(200).json({ missions });
    } catch (error) {
        console.error('인증 권한 부여 미션 조회 오류:', error);
        res.status(500).json({ message: '인증 권한 부여 미션을 조회하는 중 오류가 발생했습니다.' });
    }
};

// 자신이 생성한 미션 수 출력
exports.getCreateMissionNumber = async (req, res) => {
    try {
        const userId = req.currentUserId;
        const count = await Mission.count({
            where: { u1_id: userId }
        });
        res.json({ createMissionCount: count });
    } catch (error) {
        console.error('getCreateMissionNumber error:', error);
        res.status(500).json({ message: '생성한 미션 수 조회 실패' });
    }
};

// 자신이 수행 중인 미션 수 출력
exports.getAssignedMissionNumber = async (req, res) => {
    try {
        const userId = req.currentUserId;
        const count = await Mission.count({
            where: {
                u2_id: userId,
                m_status: { [Op.in]: ['진행중', '요청'] },
            },
        });
        res.json({ assignedMissionCount: count });
    } catch (error) {
        console.error('getAssignedMissionNumber error:', error);
        res.status(500).json({ message: '수행 중인 미션 수 조회 실패' });
    }
};


// 미션 인증 요청 함수
exports.requestMissionApproval = async (req, res) => {
    const { m_id } = req.body; // 클라이언트에서 미션 ID 전달
    const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

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
        const updated = await Mission.update({ 
            m_status: '요청',
            mission_image: req.file?.buffer || null
        }, { where: { m_id, u2_id: userId }
        });

        if (updated[0] === 0) {
            return res.status(400).json({ success: false, message: '미션 상태를 변경할 수 없습니다.' });
        }

        // ================ 알림 추가 - 디바이스 토큰 =======================
        if (userId !== mission.u1_id){
            const sendRequestMissionApprovalNotification = await notificationController.sendRequestMissionApprovalNotification(
                userId,
                mission.u1_id,
            );

            if(!sendRequestMissionApprovalNotification){
                return res.status(400).json({ success: false, message: '미션 인증 요청 알림 전송을 실패했습니다.' });
            }
        }
        // ================ 알림 추가 - 디바이스 토큰 =======================


        // //============================================================================
        // const roomId = mission.r_id;
        // const messageContents = `사용자 ${mission.u1_id}가 미션 "${mission.m_title}"을(를) 요청했습니다.`;

        // await RMessage.create({
        //     u1_id: mission.u1_id,
        //     u2_id: mission.u2_id,
        //     r_id: roomId,
        //     message_contents: messageContents,
        //     send_date: new Date(),
        // });

        // // sendMessage 호출
        // sendMessage({
        //     u1_id: mission.u1_id,
        //     u2_id: mission.u2_id,
        //     r_id: roomId,
        //     message_contents: messageContents,
        // });
        // //============================================================================


        res.json({ success: true, message: '미션 상태가 "요청"으로 변경되었습니다.' });
    } catch (error) {
        console.error('미션 요청 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 요청 처리 중 오류가 발생했습니다.' });
    }
};


// 미션 성공 처리 함수
exports.successMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용
    
    try {
        const mission = await Mission.findOne({ where: { m_id } }); // ✅ m_id로 조회

        if (!mission) {
            return res.json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.missionAuthenticationAuthority !== u1_id) {
            return res.status(403).json({ success: false, message: '미션 인증 권한이 없습니다.' });
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

        const updatedMission = await Mission.findOne({ where: { m_id } });
        // 커뮤니티 미션 상태 업데이트
        await updateCommunityRoomStatusOnMissionComplete(updatedMission);

        // 현재 시간 저장
        const currentTime = new Date();

        // resultController를 통해 결과 저장
        const saveResultResponse = await resultController.saveResult(
            m_id,
            mission.u2_id,
            // mission.m_deadline,
            currentTime, // 현재 시간 전달
            '성공',
            mission.category,
            mission.mission_image,
        );

        // saveResultResponse가 성공하지 않은 경우
        if (!saveResultResponse.success) {
            return res.status(500).json({
                success: false,
                message: `결과 저장 중 오류가 발생했습니다. controller: ${saveResultResponse.error || '알 수 없는 오류'}`,
                error: saveResultResponse.error || '알 수 없는 오류',
            });
        }

        // ✅ LP 반영
        try {
            const lpReq = {
                body: {
                    user_id: mission.u2_id,
                    success: true
                }
            };
            const lpRes = {
                status: () => ({ json: () => {} }),
                json: () => {}
            };
            await leagueController.updateLpOnMission(lpReq, lpRes);
        } catch (lpError) {
            console.error('LP 업데이트 실패:', lpError);
        }

        // ================ 알림 추가 - 디바이스 토큰 =======================
        if (u1_id !== mission.u2_id){
            const sendMissionSuccessNotification = await notificationController.sendMissionSuccessNotification(
                u1_id,
                mission.u2_id,
            );

            if(!sendMissionSuccessNotification){
                return res.status(400).json({ success: false, message: '미션 성공 알림 전송을 실패했습니다.' });
            }
        }
        // ================ 알림 추가 - 디바이스 토큰 =======================

        res.json({ success: true, message: '미션이 성공으로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 성공 처리 오류:', error);
        res.status(500).json({ success: false, message: `미션 인증 성공 처리 중 ${error}오류가 발생했습니다.` });
    }
};

// 미션 실패 처리 함수
exports.failureMission = async (req, res) => {
    const { m_id } = req.body;
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용
    try {
        const mission = await Mission.findOne({ where: { m_id, u1_id } });

        if (!mission) {
            return res.json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.missionAuthenticationAuthority !== u1_id) {
            return res.status(403).json({ success: false, message: '미션 인증 권한이 없습니다.' });
        }

        // m_status가 "요청"일 때만 상태 변경 가능
        if (mission.m_status !== '요청') {
            return res.json({ success: false, message: '현재 상태에서는 미션을 성공으로 변경할 수 없습니다.' });
        }

        await Mission.update(
            { m_status: '완료' },
            { where: { m_id, u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
        );

        const updatedMission = await Mission.findOne({ where: { m_id } });
        // 커뮤니티 미션 상태 업데이트
        await updateCommunityRoomStatusOnMissionComplete(updatedMission);

        // 현재 시간 저장
        const currentTime = new Date();

        // resultController를 통해 결과 저장
        const saveResultResponse = await resultController.saveResult(
            m_id,
            mission.u2_id,
            // mission.m_deadline,
            currentTime, // 현재 시간 전달
            '실패',
            mission.category,
            mission.mission_image,
        );

        // saveResultResponse가 성공하지 않은 경우
        if (!saveResultResponse.success) {
            return res.status(500).json({
                success: false,
                message: `결과 저장 중 오류가 발생했습니다. controller: ${saveResultResponse.error || '알 수 없는 오류'}`,
                error: saveResultResponse.error || '알 수 없는 오류',
            });
        }

        // ✅ LP 반영
        try {
            const lpReq = {
                body: {
                    user_id: mission.u2_id,
                    success: false
                }
            };
            const lpRes = {
                status: () => ({ json: () => {} }),
                json: () => {}
            };
            await leagueController.updateLpOnMission(lpReq, lpRes);
        } catch (lpError) {
            console.error('LP 업데이트 실패:', lpError);
        }

        // ================ 알림 추가 - 디바이스 토큰 =======================
        if (u1_id !== mission.u2_id){
            const sendMissionFailureNotification = await notificationController.sendMissionFailureNotification(
                u1_id,
                mission.u2_id,
            );

            if(!sendMissionFailureNotification){
                return res.status(400).json({ success: false, message: '미션 실패 알림 전송을 실패했습니다.' });
            }
        }
        // ================ 알림 추가 - 디바이스 토큰 =======================

        res.json({ success: true, message: '미션이 실패로 갱신되었습니다.' });
    } catch (error) {
        console.error('미션 실패 처리 오류:', error);
        res.status(500).json({ success: false, message: '미션 인증 실패 처리 중 오류가 발생했습니다.' });
    }
};

//방미션출력
exports.printRoomMission = async (req, res) => {
    const { u2_id } = req.body; // 클라이언트에서 상대방 ID 전달
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

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

        const exactTenMinutesLater = new Date(now.getTime() + 10 * 60 * 1000); // 10분 뒤 시간

        // 10분 뒤에 마감 기한이 설정된 미션 조회
        const missionsWithExactTenMinutesLeft = await Mission.findAll({
            where: {
                m_deadline: exactTenMinutesLater, // 정확히 10분 후
                m_status: { [Op.or]: ['진행중', '요청'] }, // 상태가 "진행중" 또는 "요청"
            },
        });

        // 10분 남은 미션들 알림 보내기
        for (const missionTenMinutes of missionsWithExactTenMinutesLeft) {
            // ================ 알림 추가 - 디바이스 토큰 =======================
            const sendMissionDeadlineTenMinutesNotification = await notificationController.sendMissionDeadlineTenMinutesNotification(
                missionTenMinutes.u2_id,
                missionTenMinutes.m_title,
            );

            if(!sendMissionDeadlineTenMinutesNotification){
                return res.status(400).json({ success: false, message: '미션 마감기한 임박 알림 전송을 실패했습니다.' });
            }
            // ================ 알림 추가 - 디바이스 토큰 =======================
        }


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

                // 커뮤니티 미션 상태 업데이트 함수 호출
                await updateCommunityRoomStatusOnMissionComplete(mission);

                // ✅ LP 반영
                try {
                    const lpReq = {
                        body: {
                            user_id: mission.u2_id,
                            success: true
                        }
                    };
                    const lpRes = {
                        status: () => ({ json: () => {} }),
                        json: () => {}
                    };
                    await leagueController.updateLpOnMission(lpReq, lpRes);
                } catch (lpError) {
                    console.error('LP 업데이트 실패:', lpError);
                }

                await MResult.create({
                    m_id: mission.m_id,
                    u_id: mission.u2_id,
                    m_deadline: originalDeadline, // 원래 마감 기한 저장
                    m_status: '실패',
                    category: mission.category,
                });

                // //==============================리워드 기능 추가==============================
                // // 미션 생성자 reward 50 삭감
                // await User.update(
                //     { reward: Sequelize.literal('CASE WHEN reward - 25 < 0 THEN 0 ELSE reward - 25 END') },
                //     { where: { u_id: mission.u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
                // );
                // // 미션 성공자 reward 100 삭감
                // await User.update(
                //     { reward: Sequelize.literal('CASE WHEN reward - 50 < 0 THEN 0 ELSE reward - 50 END') },
                //     { where: { u_id: mission.u2_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
                // );
                // //==============================리워드 기능 추가==============================

                // ================ 알림 추가 - 디바이스 토큰 =======================
                const sendMissionDeadlineNotification = await notificationController.sendMissionDeadlineNotification(
                    mission.u2_id,
                    mission.m_title,
                );

                if(!sendMissionDeadlineNotification){
                    return res.status(400).json({ success: false, message: '미션 마감기한 경과 알림 전송을 실패했습니다.' });
                }
                // ================ 알림 추가 - 디바이스 토큰 =======================


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

                // 커뮤니티 미션 상태 업데이트 함수 호출
                await updateCommunityRoomStatusOnMissionComplete(mission);

                // ✅ LP 반영
                try {
                    const lpReq = {
                        body: {
                            user_id: mission.u2_id,
                            success: true
                        }
                    };
                    const lpRes = {
                        status: () => ({ json: () => {} }),
                        json: () => {}
                    };
                    await leagueController.updateLpOnMission(lpReq, lpRes);
                } catch (lpError) {
                    console.error('LP 업데이트 실패:', lpError);
                }

                await MResult.create({
                    m_id: mission.m_id,
                    u_id: mission.u2_id,
                    m_deadline: originalDeadline, // 원래 마감 기한 저장
                    m_status: '실패',
                    category: mission.category,
                });

                // //==============================리워드 기능 추가==============================
                // // 미션 생성자 reward 50 삭감
                // await User.update(
                //     { reward: Sequelize.literal('CASE WHEN reward - 25 < 0 THEN 0 ELSE reward - 25 END') },
                //     { where: { u_id: mission.u1_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
                // );
                // // 미션 성공자 reward 100 삭감
                // await User.update(
                //     { reward: Sequelize.literal('CASE WHEN reward - 50 < 0 THEN 0 ELSE reward - 50 END') },
                //     { where: { u_id: mission.u2_id } } // u1_id를 조건에 포함하여 로그인된 사용자의 미션만 업데이트
                // );
                // //==============================리워드 기능 추가==============================

                // ================ 알림 추가 - 디바이스 토큰 =======================
                const sendMissionDeadlineNotification = await notificationController.sendMissionDeadlineNotification(
                    mission.u2_id,
                    mission.m_title,
                );

                if(!sendMissionDeadlineNotification){
                    return res.status(400).json({ success: false, message: '미션 마감기한 경과 알림 전송을 실패했습니다.' });
                }
                // ================ 알림 추가 - 디바이스 토큰 =======================

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

// ===================== 투표 요청 ===============================

// 자신이 만든 미션 목록, 상태 : 진행중
exports.getRequestedSelfMissions = async (req, res) => {
    const userId = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    try {
        // 자신이 자기 자신에게 생성한 상태가 "진행중"인 미션 조회
        const missions = await Mission.findAll({
            where: {
                u1_id: userId,
                u2_id: userId,
                m_status: '진행중', // 상태가 "진행중"인 미션만 필터링
            },
        });

        res.status(200).json({ missions });
    } catch (error) {
        console.error('자신에게 생성한 진행중 상태의 미션 조회 오류:', error);
        res.status(500).json({ message: '진행중 상태의 미션을 조회하는 중 오류가 발생했습니다.' });
    }
};

// 개인 미션을 투표에 업로드
exports.requestVoteForMission = async (req, res) => {
    const { m_id } = req.body;
    const c_image = req.file ? req.file.buffer : null; // 사진 데이터 처리
    // const c_image = req.file ? req.file : null;

    if (!m_id) {
        return res.status(400).json({ success: false, message: '미션 ID가 누락되었습니다.' });
    }

    try {
        // m_id를 기반으로 미션 정보 가져오기
        const mission = await Mission.findOne({ where: { m_id } });

        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션을 찾을 수 없습니다.' });
        }

        // ===== 추가된 기능: 미션 상태를 "요청"으로 변경 =====
        const updated = await Mission.update(
            { m_status: '요청' }, // 상태를 "요청"으로 변경
            { where: { m_id } }  // m_id 조건으로 업데이트
        );

        if (updated[0] === 0) {
            return res.status(400).json({ success: false, message: '미션 상태 변경에 실패했습니다.' });
        }

        const { u1_id, m_title, m_deadline } = mission;
        // const c_number = uuidv4(); // 고유 투표 번호 생성
        const c_number = m_id;
        const c_deletedate = new Date(new Date(m_deadline).getTime() + 3 * 24 * 60 * 60 * 1000); // 마감일 + 3일

        // 투표 생성
        const newVote = await CVote.create({
            u_id: u1_id,
            c_number,
            c_title: m_title,
            c_contents: `미션 "${m_title}"의 투표`,
            c_good: 0,
            c_bad: 0,
            c_deletedate,
            c_image, // 사진 저장 (null일 수도 있음)
        });

        res.json({ success: true, message: '투표가 성공적으로 생성되었습니다.', vote: newVote });
    } catch (error) {
        console.error('투표 요청 중 오류:', error);
        res.status(500).json({ success: false, message: '투표 생성 중 오류가 발생했습니다.' });
    }
};

 
// 추천 미션 기반으로 미션 생성
exports.createMissionFromRecommendation = async (req, res) => {
    const { m_title } = req.body; // 추천 미션 제목
    // const u1_id = req.session?.user?.id; // 현재 로그인된 사용자 ID
    const u1_id = req.currentUserId; // ✅ JWT에서 추출한 사용자 ID 사용

    if (!u1_id || !m_title) {
        return res.status(400).json({ success: false, message: '필수 데이터가 누락되었습니다.' });
    }

    try {
        const now = new Date();
        const deadline = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59); // 금일 23:59:59

        const room = await Room.findOne({ where: { u1_id:u1_id, u2_id:u1_id } });

        if (!room) {
            return res.status(400).json({ success: false, message: '사용자 방이 존재하지 않습니다.' });
        }

        await Mission.create({
            m_id: uuidv4(),               // 고유한 미션 ID 생성
            u1_id,                        // 현재 로그인된 사용자
            u2_id: u1_id,                 // 수행자도 현재 사용자
            m_title,                      // 추천 미션 제목
            m_deadline: deadline,         // 마감기한
            m_reword: null,               // 보상은 없음
            m_status: '진행중',           // 기본 상태는 '진행중'
            r_id: room.r_id,
            m_extended: 'false',
            missionAuthenticationAuthority: u1_id, // 인증 권한은 본인
        });

        res.status(201).json({ success: true, message: '추천 미션이 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('추천 미션 생성 오류:', error);
        res.status(500).json({ success: false, message: '추천 미션 생성 중 오류가 발생했습니다.' });
    }
};