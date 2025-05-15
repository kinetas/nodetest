const axios = require('axios'); // 내부 API 호출을 위해 추가
const CRoom = require('../models/comunity_roomModel'); // comunity_room 모델 가져오기
const Room = require('../models/roomModel'); // room 모델
const Mission = require('../models/missionModel'); // mission 모델
const MResult = require('../models/m_resultModel');
const CRecom = require('../models/community_recommendationModel')
const CommunityComment = require('../models/comunity_commentModel')
const CommunityCommentCmtRecom = require('../models/comment_recommendationModel');
const User = require('../models/userModel');
const notificationController = require('../controllers/notificationController'); // notificationController 가져오기
const Sequelize = require('sequelize');
const { sequelize } = require('../models/comunity_roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // [추가됨]

// // 첫 번째 조건: 커뮤니티 미션 생성
// exports.createCommunityMission = async (req, res) => {
//     // const { cr_title } = req.body; // 제목 입력 받기
//     const { cr_title, contents, deadline } = req.body;
//     const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
//     const cr_num = uuidv4(); // 랜덤 값 생성
//     const cr_status = "match";
//     const m1_status = "0";
//     const m2_status = "0";

//     try {
//         // await CRoom.create({ u_id, cr_num, cr_title, cr_status, m1_status, m2_status });
//         await CRoom.create({ u_id, cr_num, cr_title, cr_status, m1_status, m2_status, contents, deadline });
//         res.json({ success: true, message: '커뮤니티 미션이 성공적으로 생성되었습니다.' });
//     } catch (error) {
//         console.error('커뮤니티 미션 생성 오류:', error);
//         res.status(500).json({ success: false, message: '커뮤니티 미션 생성 중 오류가 발생했습니다.' });
//     }
// };

// // 두 번째 조건: 커뮤니티 미션 수락
// exports.acceptCommunityMission = async (req, res) => {
//     const { cr_num } = req.body; // 미션 번호 가져오기
//     const u2_id = req.session.user.id; // 세션에서 사용자 ID 가져오기

//     try {
//         const mission = await CRoom.findOne({ where: { cr_num } });
//         // const room = await Room.findOne({ where: { u1_id, u2_id } });
//         if (!mission) {
//             return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
//         }

//         if (mission.u_id === u2_id) {
//             return res.status(403).json({ success: false, message: '본인이 생성한 미션은 수락할 수 없습니다.' });
//         }
//         if(mission.cr_status == 'acc'){
//             return res.status(403).json({ success: false, message: '이미 수락된 미션입니다.' });
//         }

//         // [추가됨] 방 존재 여부 확인
//         const rooms = await Room.findAll({
//             where: {
//                 r_type: 'open', // 방 타입 조건
//                 [Op.or]: [
//                     { u1_id: mission.u_id, u2_id }, // 첫 번째 조합
//                     { u1_id: u2_id, u2_id: mission.u_id } // 반대 조합
//                 ]
//             }
//         });

//         let rid_u1_u2 = uuidv4();
//         let rid_u2_u1 = uuidv4();
//         let rid_open = uuidv4();

//         if (rooms.length === 0) {
//             // [추가됨] 방 생성
//             roomId = uuidv4();
//             await Room.create({ 
//                 u1_id: mission.u_id, 
//                 u2_id, 
//                 // r_id: rid_u1_u2, 
//                 r_id: rid_open,
//                 r_title: `${mission.u_id}-${u2_id}`, 
//                 r_type: 'open' 
//             });

//             await Room.create({ 
//                 u1_id: u2_id, 
//                 u2_id: mission.u_id, 
//                 // r_id: rid_u2_u1, 
//                 r_id: rid_open,
//                 r_title: `${u2_id}-${mission.u_id}`, 
//                 r_type: 'open' 
//             });
//         } else {
//             // [변경됨] 기존 방 ID 사용
//             // rid_u1_u2 = rooms.find(r => r.u1_id === mission.u_id && r.u2_id === u2_id)?.r_id || uuidv4();
//             // rid_u2_u1 = rooms.find(r => r.u1_id === u2_id && r.u2_id === mission.u_id)?.r_id || uuidv4();
//             rid_open = rooms.find(r => r.u1_id === u2_id && r.u2_id === mission.u_id)?.r_id || uuidv4();
//         }

//         // 커뮤니티 미션 업데이트
//         await mission.update({ u2_id, cr_status: 'acc' });


//         // // Room 테이블에 데이터 생성
//         // await Room.create({ 
//         //     u1_id: mission.u_id, 
//         //     u2_id, 
//         //     r_id: rid_u1_u2, 
//         //     r_title: `${mission.u_id}-${u2_id}`, 
//         //     r_type: 'open' 
//         // });

//         // // 반대 Room 테이블에 데이터 생성
//         // await Room.create({ 
//         //     u1_id: u2_id, 
//         //     u2_id: mission.u_id, 
//         //     r_id: rid_u2_u1, 
//         //     r_title: `${u2_id}-${mission.u_id}`, 
//         //     r_type: 'open' 
//         // });

//         // Mission 테이블에 미션 생성
//         const newMissionId1 = uuidv4();
//         const newMissionId2 = uuidv4();
//         const missionTitle = mission.cr_title;

//         const currentDate = new Date();
//         // const deadline = new Date(currentDate.setDate(currentDate.getDate() + 3));
//         const deadline = mission.deadline ? mission.deadline : new Date(currentDate.setDate(currentDate.getDate() + 3));

//         await Mission.create({
//             m_id: newMissionId1,
//             u1_id: mission.u_id,
//             u2_id,
//             m_title: missionTitle,
//             m_deadline: deadline,
//             m_reword: null,
//             m_status: '진행중',
//             // r_id: rid_u1_u2,
//             r_id: rid_open,
//             m_extended: false,
//             missionAuthenticationAuthority: mission.u_id,
//         });

//         await Mission.create({
//             m_id: newMissionId2,
//             u1_id: u2_id,
//             u2_id: mission.u_id,
//             m_title: missionTitle,
//             m_deadline: deadline,
//             m_reword: null,
//             m_status: '진행중',
//             // r_id: rid_u2_u1,
//             r_id: rid_open,
//             m_extended: false,
//             missionAuthenticationAuthority: u2_id,
//         });

//         // ================ 알림 추가 - 디바이스 토큰 =======================
        
//         const sendAcceptCommunityMissionNotification = await notificationController.sendAcceptCommunityMissionNotification(
//             mission.u_id,
//             missionTitle
//         );

//         if(!sendAcceptCommunityMissionNotification){
//             return res.status(400).json({ success: false, message: '커뮤니티 미션 수락 알림 전송을 실패했습니다.' });
//         }
        
//         // ================ 알림 추가 - 디바이스 토큰 =======================

//         res.json({ success: true, message: '커뮤니티 미션이 성공적으로 수락되었습니다.' });
//     } catch (error) {
//         console.error('커뮤니티 미션 수락 오류:', error);
//         res.status(500).json({ success: false, message: `커뮤니티 미션 수락 중 오류(${error})가 발생했습니다.` });
//     }
// };

// // 세 번째 조건: 커뮤니티 미션 삭제
// exports.deleteCommunityMission = async (req, res) => {
//     const { cr_num } = req.body;
//     const u_id = req.session.user.id;

//     try {
//         const mission = await CRoom.findOne({ where: { cr_num, u_id } });

//         if (!mission) {
//             return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
//         }

//         if (mission.cr_status !== 'match') {
//             return res.status(403).json({ success: false, message: 'match 상태의 미션만 삭제할 수 있습니다.' });
//         }

//         await mission.destroy();
//         res.json({ success: true, message: '커뮤니티 미션이 성공적으로 삭제되었습니다.' });
//     } catch (error) {
//         console.error('커뮤니티 미션 삭제 오류:', error);
//         res.status(500).json({ success: false, message: '커뮤니티 미션 삭제 중 오류가 발생했습니다.' });
//     }
// };


//======================Token===============================

//============미션===============

function shortenContent(content, maxLength = 100) {
    if (!content) return '';
    return content.length > maxLength ? content.slice(0, maxLength) + '...' : content;
}

// 커뮤니티 미션 생성 (JWT 적용)
exports.createCommunityMission = async (req, res) => {
    const { cr_title, contents, deadline, category } = req.body;
    const u_id = req.currentUserId; // JWT 인증된 사용자 ID 사용
    const cr_num = uuidv4();
    const cr_status = "match";
    const maded_time = new Date();

    try {
        await CRoom.create({ u_id, cr_num, cr_title, cr_status, contents, deadline, category, maded_time });
        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 생성 오류:', error);
        res.status(500).json({ success: false, message: '커뮤니티 미션 생성 중 오류가 발생했습니다.' });
    }
};

// // 커뮤니티 미션 수락 (JWT 적용)
// exports.acceptCommunityMission = async (req, res) => {
//     const { cr_num } = req.body;
//     const u2_id = req.currentUserId; // JWT 인증된 사용자 ID 사용

//     try {
//         const mission = await CRoom.findOne({ where: { cr_num } });

//         if (!mission) {
//             return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
//         }

//         if (mission.u_id === u2_id) {
//             return res.status(403).json({ success: false, message: '본인이 생성한 미션은 수락할 수 없습니다.' });
//         }
//         if (mission.cr_status == 'acc') {
//             return res.status(403).json({ success: false, message: '이미 수락된 미션입니다.' });
//         }

//         // 기존 방 조회 후 없으면 방 생성
//         const existingRooms = await Room.findAll({
//             where: {
//                 r_type: 'open',
//                 [Op.or]: [
//                     { u1_id: mission.u_id, u2_id },
//                     { u1_id: u2_id, u2_id: mission.u_id }
//                 ]
//             }
//         });

//         let rid_open = uuidv4();

//         if (existingRooms.length === 0) {
//             await Room.create({ u1_id: mission.u_id, u2_id, r_id: rid_open, r_type: 'open' });
//             await Room.create({ u1_id: u2_id, u2_id: mission.u_id, r_id: rid_open, r_type: 'open' });
//         } else {
//             rid_open = existingRooms[0].r_id;
//         }

//         // 커뮤니티 미션 상태 업데이트
//         await mission.update({ u2_id, cr_status: 'acc' });

//         // Mission 테이블에 미션 생성
//         const newMissionId1 = uuidv4();
//         const newMissionId2 = uuidv4();
//         const missionTitle = mission.cr_title;
//         const deadline = mission.deadline ? mission.deadline : new Date();

//         await Mission.create({
//             m_id: newMissionId1,
//             u1_id: mission.u_id,
//             u2_id,
//             m_title: missionTitle,
//             m_deadline: deadline,
//             m_status: '진행중',
//             r_id: rid_open,
//             m_extended: false,
//         });

//         await Mission.create({
//             m_id: newMissionId2,
//             u1_id: u2_id,
//             u2_id: mission.u_id,
//             m_title: missionTitle,
//             m_deadline: deadline,
//             m_status: '진행중',
//             r_id: rid_open,
//             m_extended: false,
//         });

//         res.json({ success: true, message: '커뮤니티 미션이 성공적으로 수락되었습니다.' });
//     } catch (error) {
//         console.error('커뮤니티 미션 수락 오류:', error);
//         res.status(500).json({ success: false, message: `커뮤니티 미션 수락 중 오류(${error})가 발생했습니다.` });
//     }
// };

// ✅ 커뮤니티 미션 수락 (roomController의 addRoom 사용)
exports.acceptCommunityMission = async (req, res) => {
    const { cr_num } = req.body;
    const u2_id = req.currentUserId;

    try {
        const mission = await CRoom.findOne({ where: { cr_num } });

        if (!mission) {
            return res.status(404).json({ success: false, message: '해당 미션이 존재하지 않습니다.' });
        }

        if (mission.u_id === u2_id) {
            return res.status(403).json({ success: false, message: '본인이 생성한 미션은 수락할 수 없습니다.' });
        }
        if (mission.cr_status === 'acc') {
            return res.status(403).json({ success: false, message: '이미 수락된 미션입니다.' });
        }

        // ✅ 1. 기존 open방 존재 여부 확인
        let openRoom = await Room.findOne({
            where: {
                r_type: 'open',
                [Op.or]: [
                    { u1_id: mission.u_id, u2_id },
                    { u1_id: u2_id, u2_id: mission.u_id }
                ]
            }
        });

        // ✅ 2. 없으면 roomController의 addRoom 함수 호출 (내부 API 요청)
        if (!openRoom) {
            const addRoomRes = await axios.post(
                'http://27.113.11.48:3000/api/rooms',
                {
                    u2_id: mission.u_id,
                    r_type: 'open'
                },
                {
                    headers: {
                        Authorization: req.headers.authorization // JWT 토큰 그대로 전달
                    }
                }
            );

            if (addRoomRes.data && addRoomRes.data.room) {
                openRoom = addRoomRes.data.room;
            }
        }

        const rid_open = openRoom?.r_id;

        // ✅ 3. 상태 변경
        await mission.update({ u2_id, cr_status: 'acc' });

        const deadline = mission.deadline || new Date();

        // ✅ 4. 양방향 미션 생성
        await Mission.bulkCreate([
            {
                m_id: uuidv4(),
                u1_id: mission.u_id,
                u2_id,
                m_title: mission.cr_title,
                m_deadline: deadline,
                m_status: '진행중',
                r_id: rid_open,
                m_extended: false,
                missionAuthenticationAuthority: mission.u_id,
                category: mission.category,
            },
            {
                m_id: uuidv4(),
                u1_id: u2_id,
                u2_id: mission.u_id,
                m_title: mission.cr_title,
                m_deadline: deadline,
                m_status: '진행중',
                r_id: rid_open,
                m_extended: false,
                missionAuthenticationAuthority: u2_id,
                category: mission.category,
            }
        ]);

        //         // ================ 알림 추가 - 디바이스 토큰 =======================
                
        //         const sendAcceptCommunityMissionNotification = await notificationController.sendAcceptCommunityMissionNotification(
        //             mission.u_id,
        //             missionTitle
        //         );

        //         if(!sendAcceptCommunityMissionNotification){
        //             return res.status(400).json({ success: false, message: '커뮤니티 미션 수락 알림 전송을 실패했습니다.' });
        //         }
                
        //         // ================ 알림 추가 - 디바이스 토큰 =======================

        res.json({ success: true, message: '커뮤니티 미션이 성공적으로 수락되었습니다.' });
    } catch (error) {
        console.error('커뮤니티 미션 수락 오류:', error);
        res.status(500).json({ success: false, message: `커뮤니티 미션 수락 중 오류: ${error.message}` });
    }
};

// 커뮤니티 미션 삭제 (JWT 적용)
exports.deleteCommunityMission = async (req, res) => {
    const { cr_num } = req.body;
    const u_id = req.currentUserId; // JWT 인증된 사용자 ID 사용

    try {
        const mission = await CRoom.findOne({ where: { cr_num, u_id } });

        if (!mission) {
            return res.status(404).json({ success: false, message: '타인이 생성한 미션은 삭제할 수 없습니다.' });
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

// 커뮤니티 미션 불러오기 (JWT 적용)
exports.getCommunityMission = async (req, res) => {
    try {
        const missions = await CRoom.findAll({
            where: { community_type: 'mission' },
            order: [['deadline', 'ASC']], // deadline 기준 오름차순 정렬
        }); // 모든 커뮤니티 미션 가져오기
        res.json({ missions });
    } catch (error) {
        console.error('커뮤니티 미션 리스트 오류:', error);
        res.status(500).json({ message: '커뮤니티 미션 리스트를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 커뮤니티 미션 리스트 출력 - 내용 간략화 버전
exports.getCommunityMissionSimple = async (req, res) => {
    try {
        const missions = await CRoom.findAll({
            where: { community_type: 'mission' },
            order: [['deadline', 'ASC']],
        });

        const missionList = missions.map(m => ({
            cr_num: m.cr_num,
            cr_title: m.cr_title,
            contents: shortenContent(m.contents, 100),
            cr_status: m.cr_status,
            deadline: m.deadline
        }));

        res.json({ missions: missionList });
    } catch (error) {
        console.error('커뮤니티 미션 간략 리스트 오류:', error);
        res.status(500).json({ message: '커뮤니티 미션 리스트를 불러오는 중 오류 발생' });
    }
};


//============일반===============

// 일반 커뮤니티 생성 함수
exports.createCommunity = async (req, res) => {
    const { cr_title, contents, community_type } = req.body;
    const image = req.file ? req.file.buffer : null;
    const u_id = req.currentUserId;
    const cr_num = uuidv4();

    try {
        await CRoom.create({
            u_id, cr_num, cr_title, contents, community_type,
            hits: 0, recommended_num: 0, maded_time: new Date(), image
        });
        res.json({ success: true, message: '일반 커뮤니티가 성공적으로 생성되었습니다.' });
    } catch (error) {
        console.error('일반 커뮤니티 생성 오류:', error);
        res.status(500).json({ success: false, message: '일반 커뮤니티 생성 중 오류가 발생했습니다.' });
    }
};

//일반 커뮤니티 글 삭제 함수
exports.deleteGeneralCommunity = async (req, res) => {
    const { cr_num } = req.body;
    const u_id = req.currentUserId;

    try {
        const post = await CRoom.findOne({ where: { cr_num, u_id, community_type: 'general' } });
        console.log("cr_num(controller): ", cr_num);
        if (!post) {
            return res.status(404).json({ success: false, message: '게시글을 찾을 수 없습니다.' });
        }

        await post.destroy();
        res.json({ success: true, message: '일반 커뮤니티 글이 삭제되었습니다.' });
    } catch (error) {
        console.error('삭제 오류:', error);
        res.status(500).json({ success: false, message: '삭제 중 오류가 발생했습니다.' });
    }
};

// 일반 커뮤니티 리스트 출력 함수
exports.printGeneralCommunity = async (req, res) => {
    try {
        const communities = await CRoom.findAll({
            where: { community_type: 'general' },
            order: [['maded_time', 'DESC']]
        });
        const communityList = communities.map(c => ({
            cr_num: c.cr_num,
            cr_title: c.cr_title,
            contents: c.contents,
            hits: c.hits,
            recommended_num: c.recommended_num,
            maded_time: c.maded_time,
            image: c.image ? c.image.toString('base64') : null
        }));

        res.json({ communities: communityList });
    } catch (error) {
        console.error('일반 커뮤니티 리스트 출력 오류:', error);
        res.status(500).json({ message: '일반 커뮤니티 리스트를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 일반 커뮤니티 글 리스트 출력 - 내용 간략화 버전
exports.printGeneralCommunitySimple = async (req, res) => {
    try {
        const communities = await CRoom.findAll({
            where: { community_type: 'general' },
            order: [['maded_time', 'DESC']]
        });

        const communityList = communities.map(c => ({
            cr_num: c.cr_num,
            cr_title: c.cr_title,
            contents: shortenContent(c.contents, 100),
            hits: c.hits,
            recommended_num: c.recommended_num,
            maded_time: c.maded_time,
            image: c.image ? c.image.toString('base64') : null
        }));

        res.json({ communities: communityList });
    } catch (error) {
        console.error('일반 커뮤니티 간략 리스트 오류:', error);
        res.status(500).json({ message: '일반 커뮤니티 리스트를 불러오는 중 오류 발생' });
    }
};


//============추천, 인기===============

// ✅ 인기글 여부 갱신 함수
function updatePopularity(community) {
    if (community.popularity) return Promise.resolve(); // ✅ 이미 인기글이면 유지

    const now = new Date();
    const createdTime = new Date(community.maded_time);
    const minutes = (now - createdTime) / (1000 * 60);

    let isPopular = false;
    if (minutes <= 30 && community.recommended_num >= 5) {  //30분안에 추천 5개 이상
        isPopular = true;
    } else if (minutes <= 60 && community.recommended_num >= 30) {  //1시간 안에 추천 30개 이상
        isPopular = true;
    } else if (minutes <= 1440 && community.recommended_num >= 100) {  //24시간 안에 추천 100개 이상
        isPopular = true;
    } else if (minutes <= 1440*7 && community.recommended_num >= 300) {  //일주일 안에 추천 300개 이상
        isPopular = true;
    }

    if (isPopular) {
        return community.update({ popularity: true }); // ✅ 처음 인기글로 진입 시에만 true로 설정
    }
    return Promise.resolve(); // ✅ false로 다시 바꾸지 않음
}

//추천
exports.recommendCommunity = async (req, res) => {
    const { cr_num } = req.body;
    const u_id = req.currentUserId;

    try {
        const community = await CRoom.findOne({ where: { cr_num } });
        if (!community) return res.status(404).json({ success: false, message: '커뮤니티 글을 찾을 수 없습니다.' });
        
        const existingRecommendation = await CRecom.findOne({ where: { cr_num, u_id } });

        if (existingRecommendation) {
            // 이미 추천한 상태이면 추천 취소 (토글)
            if (existingRecommendation.recommended) {
                await existingRecommendation.update({ recommended: false });
                await CRoom.decrement('recommended_num', { where: { cr_num } });
                await updatePopularity(community);// ✅ 인기글 여부 업데이트
                res.json({ success: true, message: '추천을 취소했습니다.' });
            } else {
                // 추천이 취소된 상태라면 다시 추천 활성화
                await existingRecommendation.update({ recommended: true });
                await CRoom.increment('recommended_num', { where: { cr_num } });
                await updatePopularity(community);// ✅ 인기글 여부 업데이트
                res.json({ success: true, message: '다시 추천했습니다.' });
            }
        } else {
            // 처음 추천하는 경우
            await CRecom.create({ cr_num, u_id, recommended: true });
            await CRoom.increment('recommended_num', { where: { cr_num } });
            await updatePopularity(community);// ✅ 인기글 여부 업데이트
            res.json({ success: true, message: '추천했습니다.' });
        }
    } catch (error) {
        console.error('추천 오류:', error);
        res.status(500).json({ success: false, message: '추천 처리 중 오류가 발생했습니다.' });
    }
};

// 인기글 리스트 (JWT 적용)
exports.getPopularyityCommunity = async (req, res) => {
    try {
        const communities = await CRoom.findAll({
            where: { popularity: true },
            order: [['deadline', 'ASC']],
        });

        const communityList = communities.map(c => ({
            cr_num: c.cr_num,
            cr_title: c.cr_title,
            contents: c.contents,
            hits: c.hits,
            recommended_num: c.recommended_num,
            maded_time: c.maded_time,
            image: c.image ? c.image.toString('base64') : null
        }));

        res.json({ communities: communityList });
    } catch (error) {
        console.error('인기글 리스트 오류:', error);
        res.status(500).json({ message: '인기글 리스트를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 인기글 리스트 출력 - 내용 간략화 버전
exports.getPopularyityCommunitySimple = async (req, res) => {
    try {
        const communities = await CRoom.findAll({
            where: { popularity: true },
            order: [['deadline', 'ASC']],
        });

        const communityList = communities.map(c => ({
            cr_num: c.cr_num,
            cr_title: c.cr_title,
            contents: shortenContent(c.contents, 100),
            hits: c.hits,
            recommended_num: c.recommended_num,
            maded_time: c.maded_time,
            image: c.image ? c.image.toString('base64') : null
        }));

        res.json({ communities: communityList });
    } catch (error) {
        console.error('인기글 간략 리스트 오류:', error);
        res.status(500).json({ message: '인기글 리스트를 불러오는 중 오류 발생' });
    }
};

//====== 상세보기, 댓글 =======
// cr_num으로 커뮤니티 하나 불러오기 (JWT 적용)
exports.getOneCommunity = async (req, res) => {
    const { cr_num } = req.body;
    
    try {
        const communities = await CRoom.findOne({
            where: { cr_num: cr_num },
        });

        if (!communities) {
            return res.status(404).json({ message: '해당 커뮤니티 글을 찾을 수 없습니다.' });
        }

        // ✅ 이미지가 있으면 Base64로 변환
        if (communities.image) {
            communities.image = communities.image.toString('base64');
        }

        res.json({ communities });
    } catch (error) {
        console.error('단일 커뮤니티 가져오기 오류:', error);
        res.status(500).json({ message: '단일 커뮤니티를 불러오는 중 오류가 발생했습니다.' });
    }
};

// cr_num으로 댓글 리스트 불러오기 (JWT 적용)
exports.getCommunityComments = async (req, res) => {
    const { cr_num } = req.body;
    
    try {
        const comments = await CommunityComment.findAll({
            where: { cr_num: cr_num },
            order: [['created_time', 'ASC']],
        });

        if (!comments) {
            return res.status(404).json({ message: '해당 댓글을 찾을 수 없습니다.' });
        }

        res.json({ comments });
    } catch (error) {
        console.error('단일 커뮤니티 가져오기 오류:', error);
        res.status(500).json({ message: '단일 커뮤니티를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 댓글 작성 (JWT 적용)
exports.writeComment = async (req, res) => {
    const { cr_num, comment } = req.body;
    const u_id = req.currentUserId;

    try {
        // 사용자 닉네임 조회
        const user = await User.findOne({ where: { u_id } });
        if (!user) {
            return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
        }

        // 댓글 생성
        await CommunityComment.create({
            cc_num: uuidv4(),
            cr_num,
            u_id,
            user_nickname: user.u_nickname,
            comment,
            created_time: new Date()
        });

        res.json({ success: true, message: '댓글이 성공적으로 작성되었습니다.' });
    } catch (error) {
        console.error('댓글 작성 오류:', error);
        res.status(500).json({ success: false, message: '댓글 작성 중 오류가 발생했습니다.' });
    }
};

// 댓글 삭제 (JWT 인증 필요)
exports.deleteComment = async (req, res) => {
    const { cc_num } = req.body;
    const u_id = req.currentUserId;

    try {
        const comment = await CommunityComment.findOne({ where: { cc_num, u_id } });

        if (!comment) {
            return res.status(404).json({ success: false, message: '댓글이 존재하지 않거나 권한이 없습니다.' });
        }

        await comment.destroy();
        res.json({ success: true, message: '댓글이 삭제되었습니다.' });
    } catch (error) {
        console.error('댓글 삭제 오류:', error);
        res.status(500).json({ success: false, message: '댓글 삭제 중 오류가 발생했습니다.' });
    }
};

// 댓글 추천
exports.recommendComment = async (req, res) => {
    const { cc_num } = req.body;
    const u_id = req.currentUserId;

    try {
        const comment = await CommunityComment.findOne({ where: { cc_num } });
        if (!comment) return res.status(404).json({ success: false, message: '댓글을 찾을 수 없습니다.' });

        let existing = await CommunityCommentCmtRecom.findOne({ where: { cc_num, u_id } });

        if (existing) {
            if (existing.recommended) {
                await existing.update({ recommended: false });
                await comment.decrement('recommended_num');
                res.json({ success: true, message: '댓글 추천 취소됨' });
            } else {
                await existing.update({ recommended: true });
                await comment.increment('recommended_num');
                res.json({ success: true, message: '댓글 다시 추천됨' });
            }
        } else {
            await CommunityCommentCmtRecom.create({ cc_num, u_id, recommended: true });
            await comment.increment('recommended_num');
            res.json({ success: true, message: '댓글 추천됨' });
        }
    } catch (error) {
        console.error('댓글 추천 오류:', error);
        res.status(500).json({ success: false, message: '댓글 추천 중 오류 발생' });
    }
};

// 커뮤니티 전체 불러오기 (JWT 적용)
exports.getAllCommunity = async (req, res) => {
    try {
        const missions = await CRoom.findAll({
            order: [['deadline', 'ASC']], // deadline 기준 오름차순 정렬
        }); // 모든 커뮤니티 가져오기
        res.json({ missions });
    } catch (error) {
        console.error('모든 커뮤니티 리스트 오류:', error);
        res.status(500).json({ message: '모든 커뮤니티 리스트를 불러오는 중 오류가 발생했습니다.' });
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