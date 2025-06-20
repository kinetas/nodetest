const { Op } = require('sequelize');
const { sequelize } = require('../models/comunity_voteModel'); // sequelize 인스턴스를 models에서 가져옵니다.
const CVote = require('../models/comunity_voteModel');
const c_v_notdup = require('../models/c_v_not_dupModel'); 
const Mission = require('../models/missionModel');
const MResult = require('../models/m_resultModel');
const User = require('../models/userModel');
const notificationController = require('../controllers/notificationController'); // notificationController 가져오기
const { v4: uuidv4, validate: uuidValidate } = require('uuid');

//===================================================token================================================

exports.getVotes = async (req, res) => {
    try {
        const votes = await CVote.findAll({
            order: [[sequelize.literal("DATEDIFF(c_deletedate, CURDATE())"), "ASC"]]
        });
        res.json({ success: true, votes });
    } catch (error) {
        console.error("Error fetching votes:", error);
        res.status(500).json({ success: false, message: "투표 정보를 가져오는데 실패했습니다." });
    }
};

exports.getMyVotes = async (req, res) => {
    const u_id = req.currentUserId; // ✅ JWT에서 추출
    try {
        const myVotes = await CVote.findAll({
            where: { u_id },
            order: [["c_deletedate", "DESC"]]
        });
        res.json({ success: true, myVotes });
    } catch (error) {
        console.error("Error fetching my votes:", error);
        res.status(500).json({ success: false, message: "내 투표 정보를 가져오는데 실패했습니다." });
    }
};

exports.createVote = async (req, res) => {
    const { c_title, c_contents } = req.body;
    const u_id = req.currentUserId; // ✅ JWT에서 추출
    const c_image = req.file ? req.file.buffer : null;

    if (!u_id || !c_title || !c_contents) {
        return res.status(400).json({ success: false, message: "필수 값이 누락되었습니다." });
    }

    const c_number = uuidv4();
    if (!uuidValidate(c_number)) {
        return res.status(500).json({ success: false, message: "UUID 생성 실패" });
    }

    try {
        const newVote = await CVote.create({
            u_id,
            c_number,
            c_title,
            c_contents,
            c_good: 0,
            c_bad: 0,
            c_deletedate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
            c_image,
            vote_create_date: new Date(Date.now()),
        });
        res.json({ success: true, vote: newVote });
    } catch (error) {
        console.error("Error creating vote:", error);
        res.status(500).json({ success: false, message: "투표 생성 실패" });
    }
};

exports.voteAction = async (req, res) => {
    const { c_number, action } = req.body;
    const currentUserId = req.currentUserId; // ✅ JWT에서 추출

    if (!c_number || !['good', 'bad'].includes(action)) {
        return res.status(400).json({ success: false, message: "잘못된 요청입니다." });
    }

    try {
        const vote = await CVote.findOne({ where: { c_number } });
        if (!vote) {
            return res.status(404).json({ success: false, message: "투표를 찾을 수 없습니다." });
        }

        const now = new Date();
        if (now >= vote.c_deletedate) {
            return res.status(403).json({ success: false, message: "투표가 종료되었습니다." });
        }

        if (vote.u_id === currentUserId) {
            return res.status(403).json({ success: false, message: "자신이 생성한 투표에는 투표할 수 없습니다." });
        }

        const alreadyVoted = await c_v_notdup.findOne({
            where: { u_id: vote.u_id, c_number: vote.c_number, vote_id: currentUserId }
        });

        if (alreadyVoted) {
            return res.status(403).json({ success: false, message: "이미 투표하셨습니다." });
        }

        await c_v_notdup.create({ u_id: vote.u_id, c_number: vote.c_number, vote_id: currentUserId });

        if (action === 'good') vote.c_good += 1;
        if (action === 'bad') vote.c_bad += 1;

        await vote.save();
        res.json({ success: true, vote });
    } catch (error) {
        console.error("Error updating vote:", error);
        res.status(500).json({ success: false, message: "투표 업데이트 실패" });
    }
};

exports.deleteVote = async (req, res) => {
    const { c_number } = req.params;
    const u_id = req.currentUserId; // ✅ JWT에서 추출

    try {
        const vote = await CVote.findOne({ where: { c_number, u_id } });
        if (!vote) {
            return res.status(404).json({ success: false, message: "삭제할 투표를 찾을 수 없습니다." });
        }   
        await vote.destroy();
        res.json({ success: true, message: "투표가 삭제되었습니다." });
    } catch (error) {
        console.error("Error deleting vote:", error);
        res.status(500).json({ success: false, message: "투표 삭제 실패" });
    }
};

exports.getVoteDetails = async (req, res) => {
    const { c_number } = req.query;
    if (!c_number) {
        return res.status(400).json({ success: false, message: "유효하지 않은 c_number 값입니다." });
    }

    try {
        const vote = await CVote.findOne({ where: { c_number } });
        if (!vote) {
            return res.status(404).json({ success: false, message: "투표를 찾을 수 없습니다." });
        }

        res.json({
            success: true,
            vote: {
                c_title: vote.c_title,
                c_contents: vote.c_contents,
                u_id: vote.u_id,
                c_good: vote.c_good,
                c_bad: vote.c_bad,
                c_deletedate: vote.c_deletedate,
                c_image: vote.c_image ? vote.c_image.toString('base64') : null,
                vote_create_date: vote.vote_create_date,
            },
        });
    } catch (error) {
        console.error("Error fetching vote details:", error);
        res.status(500).json({ success: false, message: "투표 정보를 가져오는데 실패했습니다." });
    }
};


exports.checkAndUpdateMissions = async () => {
    try {
        const now = new Date();
        console.log(`[${now}] 정기 작업 실행`);

        // 현재 날짜가 데드라인을 지난 투표 조회
        const expiredVotes = await CVote.findAll({
            where: {
                c_deletedate: { [Op.lte]: now },
            },
        });

        for (const vote of expiredVotes) {
            const { c_good, c_bad, u_id, c_number } = vote;

            // c_good > c_bad 또는 투표가 없는 경우
            if (c_good > c_bad || (c_good === 0 && c_bad === 0)) {
                const missions = await Mission.findAll({
                    where: { u1_id: u_id, m_id: c_number },
                });

                for (const mission of missions) {
                    // 미션 성공 처리
                    await mission.update({ m_status: '완료' });

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
                        m_deadline: now,
                        m_status: '성공',
                        category: mission.category,
                    });

                    // ================ 알림 추가 - 디바이스 토큰 =======================
                    const sendVoteMissionSuccessNotification = await notificationController.sendVoteMissionSuccessNotification(
                        mission.u2_id,
                        mission.m_title
                    );

                    if(!sendVoteMissionSuccessNotification){
                        return res.status(400).json({ success: false, message: '투표 미션 성공 알림 전송을 실패했습니다.' });
                    }
                    
                    // ================ 알림 추가 - 디바이스 토큰 =======================

                    console.log(`미션 ${mission.m_id}이 성공 처리되었습니다.`);
                }
            } else {
                const missions = await Mission.findAll({
                    where: { u1_id: u_id, m_id: c_number },
                });

                for (const mission of missions) {
                    // 미션 실패 처리
                    await mission.update({ m_status: '완료' });

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
                        m_deadline: now,
                        m_status: '실패',
                        category: mission.category,
                    });

                    // ================ 알림 추가 - 디바이스 토큰 =======================
                    const sendVoteMissionFailureNotification = await notificationController.sendVoteMissionFailureNotification(
                        mission.u2_id,
                        mission.m_title
                    );

                    if(!sendVoteMissionFailureNotification){
                        return res.status(400).json({ success: false, message: '투표 미션 실패 알림 전송을 실패했습니다.' });
                    }
                    
                    // ================ 알림 추가 - 디바이스 토큰 =======================

                    console.log(`미션 ${mission.m_id}이 실패 처리되었습니다.`);
                }
            }
        }

        console.log(`[${now}] 정기 작업 완료: 총 ${expiredVotes.length}개의 투표를 처리했습니다.`);
    } catch (error) {
        console.error(`정기 작업 오류: ${error.message}`);
    }
};