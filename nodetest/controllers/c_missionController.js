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
// const { sequelize } = require('../models/comunity_roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // [추가됨]
const sequelize = require('../config/db');

const CVote = require('../models/comunity_voteModel');

//======================Token===============================

exports.deleteCommunityRoomAndRelatedData = async (cr_num) => {
    //중간에 오류 발생 시 일부만 삭제되는 걸 방지
    const t = await sequelize.transaction();
    try {
        const cRoom = await CRoom.findOne({ where: { cr_num } });
        if (!cRoom) return;

        // 이 방(cr_num)과 관련된 커뮤니티 댓글(cc_num) 조회
        const comments = await CommunityComment.findAll({
            where: { cr_num },
            attributes: ['cc_num'],
            transaction: t
        });

        const ccNums = comments.map(comment => comment.cc_num);

        // 댓글 추천(comment_recommendation) 삭제 (cc_num 기준)
        if (ccNums.length > 0) {
            await CommunityCommentCmtRecom.destroy({
                where: {
                    cc_num: ccNums
                },
                transaction: t
            });
        }

        // 커뮤니티 댓글 삭제
        await CommunityComment.destroy({
            where: { cr_num },
            transaction: t
        });

        // 커뮤니티 추천 삭제
        await CRecom.destroy({
            where: { cr_num },
            transaction: t
        });

        const missionIdsToDelete = [];
        if (cRoom.m1_id) missionIdsToDelete.push(cRoom.m1_id);
        if (cRoom.m2_id) missionIdsToDelete.push(cRoom.m2_id);

        if (missionIdsToDelete.length > 0) {
            await Mission.destroy({ where: { m_id: missionIdsToDelete }, transaction: t });
        }

        // 커뮤니티 방 삭제
        await CRoom.destroy({
            where: { cr_num },
            transaction: t
        });

        await t.commit();
        console.log(`✅ 커뮤니티 방 및 관련 댓글, 추천, 댓글추천 삭제 완료 (cr_num=${cr_num})`);
    } catch (err) {
        await t.rollback();
        console.error('❌ 커뮤니티 방 관련 데이터 삭제 오류:', err);
    }
};

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
                    roomName: mission.cr_title,
                    r_type: 'open'
                },
                {
                    headers: {
                        Authorization: req.headers.authorization // JWT 토큰 그대로 전달
                    }
                }
            );

            // if (addRoomRes.data && addRoomRes.data.room) {
            //     openRoom = addRoomRes.data.room;
            // }

            // ✅ 방 생성 직후 다시 조회 (양방향 대응)
            openRoom = await Room.findOne({
                where: {
                    r_type: 'open',
                    [Op.or]: [
                        { u1_id: mission.u_id, u2_id },
                        { u1_id: u2_id, u2_id: mission.u_id }
                    ]
                }
            });
        }

        const rid_open = openRoom?.r_id;

        // ✅ 3. 상태 변경
        await mission.update({ u2_id, cr_status: 'acc' });

        const deadline = mission.deadline || new Date();

        const m1_id = uuidv4();
        const m2_id = uuidv4();
        await mission.update({ m1_id, m2_id });
        console.log("m1_id: ", m1_id);
        console.log("community_room - m1_id: ", mission.m1_id);

        // ✅ 4. 양방향 미션 생성
        await Mission.bulkCreate([
            {
                m_id: m1_id,
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
                m_id: m2_id,
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

        // await mission.destroy();

        // community_room 및 관련된 댓글/추천 등도 함께 삭제
        await exports.deleteCommunityRoomAndRelatedData(cr_num);
        
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
            attributes: [
                'cr_num',
                'cr_title',
                'contents',          // DB 컬럼명이 'cr_contents'가 아닌 'contents'로 보임
                'community_type',
                'hits',
                'recommended_num',
                'cr_status',
                'maded_time'
            ],
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

// 로그인한 유저가 생성한 커뮤니티 미션 목록 조회
exports.getMyCommunityMissions = async (req, res) => {
    const u_id = req.currentUserId;

    try {
        const myMissions = await CRoom.findAll({
            where: {
                u_id,
                community_type: 'mission'
            },
            order: [['maded_time', 'DESC']]
        });

        const missionList = myMissions.map(m => ({
            cr_num: m.cr_num,
            cr_title: m.cr_title,
            contents: shortenContent(m.contents, 100),
            cr_status: m.cr_status,
            deadline: m.deadline,
            maded_time: m.maded_time,
            hits: m.hits,
            recommended_num: m.recommended_num
        }));

        res.json({ missions: missionList });
    } catch (error) {
        console.error('내 커뮤니티 미션 조회 오류:', error);
        res.status(500).json({ message: '내 커뮤니티 미션 조회 중 오류 발생' });
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
            community_type: c.community_type,
            cr_status: c.cr_status
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
            community_type: c.community_type,
            cr_status: c.cr_status
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

        // ✅ 조회수 증가
        await communities.increment('hits');

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
    
    console.log("🔥 댓글 작성 API 진입");
    console.log("req.currentUserId:", u_id);
    console.log("req.body:", req.body);
    try {
        // 사용자 닉네임 조회
        const user = await User.findOne({ where: { u_id } });
        console.log("DB 조회 결과 user:", user);
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

        // ==============  추가  ====================
        // 커뮤니티 조회
        const cr = await CRoom.findOne({ where: { cr_num } });
        if (!cr) {
            return res.status(404).json({ success: false, message: '커뮤니티를 찾을 수 없습니다.' });
        }
        // ================ 알림 추가 - 디바이스 토큰 =======================
        const sendCommentNotification = await notificationController.sendCommentNotification(
            cr.u_id,   //알림 받을 사람 = 커뮤니티 작성자
            comment,
            cr.cr_title
        );

        if(!sendCommentNotification){
            return res.status(400).json({ success: false, message: '댓글 송신 알림 전송을 실패했습니다.' });
        }
        // ================ 알림 추가 - 디바이스 토큰 =======================
        // ==============  추가  ====================

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
            attributes: [
                'cr_num',
                'cr_title',
                'contents',
                'community_type',
                'hits',
                'recommended_num',
                'cr_status',
                'maded_time'
            ],
            order: [['deadline', 'ASC']], // deadline 기준 오름차순 정렬
        }); // 모든 커뮤니티 가져오기
        res.json({ missions });
    } catch (error) {
        console.error('모든 커뮤니티 리스트 오류:', error);
        res.status(500).json({ message: '모든 커뮤니티 리스트를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 커뮤니티 (미션, 투표, 일반, 인기) 최신 두 개 가져오기
exports.getLastTwoCommunities = async (req, res) => {
    try {
        const roomData = await CRoom.findAll({
            attributes: [
                'cr_num',
                'cr_title',
                'contents',
                'community_type',
                'hits',
                'recommended_num',
                'cr_status',
                'maded_time'
            ],
            order: [['maded_time', 'DESC']],
            limit: 5
        });

        const voteData = await CVote.findAll({
            attributes: [
                ['c_number'],
                ['c_title'],
                ['c_contents'],
                ['c_good'],
                ['c_bad'],
                ['vote_create_date']
            ],
            order: [['vote_create_date', 'DESC']],
            limit: 5
        });

        // 통합 후 정렬
        const combined = [...roomData, ...voteData]
            .sort((a, b) => new Date(b.maded_time) - new Date(a.maded_time))
            .slice(0, 2); // 최신 2개만

        res.json({ latest: combined });
    } catch (error) {
        console.error('최신 커뮤니티 2개 불러오기 실패:', error);
        res.status(500).json({ message: '최신 커뮤니티 목록을 불러오는 중 오류가 발생했습니다.' });
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