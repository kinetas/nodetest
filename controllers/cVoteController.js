const { Op } = require('sequelize');
const { sequelize } = require('../models/comunity_voteModel'); // sequelize 인스턴스를 models에서 가져옵니다.
const CVote = require('../models/comunity_voteModel');
const c_v_notdup = require('../models/c_v_not_dupModel'); 
const { v4: uuidv4, validate: uuidValidate } = require('uuid');

// const jwt = require('jsonwebtoken'); // JWT 추가

// 투표 리스트 가져오기
exports.getVotes = async (req, res) => {
    try {
        const votes = await CVote.findAll({
            order: [
                [
                    sequelize.literal("DATEDIFF(c_deletedate, CURDATE())"),
                    "ASC"
                ]
            ]
        });
        res.json({ success: true, votes });
    } catch (error) {
        console.error("Error fetching votes:", error);
        res.status(500).json({ success: false, message: "투표 정보를 가져오는데 실패했습니다." });
    }
};

// // ===== JWT 기반으로 변경 =====
// exports.getVotes = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         // Fetch 투표 리스트
//         res.json({ votes: [], user: decoded });
//     } catch (error) {
//         res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//     }
// };

exports.getMyVotes = async (req, res) => {
    const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
    try {
        const myVotes = await CVote.findAll({
            where: {
                u_id
            },
            order: [["c_deletedate", "DESC"]]
        });
        res.json({ success: true, myVotes });
    } catch (error) {
        console.error("Error fetching my votes:", error);
        res.status(500).json({ success: false, message: "내 투표 정보를 가져오는데 실패했습니다." });
    }
};

// 투표 생성
exports.createVote = async (req, res) => {
    console.log("Request Body:", req.body);
    console.log("Uploaded File:", req.file);

    const { c_title, c_contents } = req.body;
    const u_id = req.session.user.id; // 세션에서 u_id 가져오기, 기본 값 설정
    const c_image = req.file ? req.file.buffer : null; // 이미지 데이터를 Buffer로 저장


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
            c_deletedate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 현재 날짜 + 3일
            c_image
        });
        res.json({ success: true, vote: newVote });
    } catch (error) {
        console.error("Error creating vote:", error);
        res.status(500).json({ success: false, message: "투표 생성 실패" });
    }
};

// 투표 액션 (좋아요/싫어요)
exports.voteAction = async (req, res) => {
    const { c_number, action } = req.body;
    const currentUserId = req.session.user.id;
    if (!c_number || !['good', 'bad'].includes(action)) {
        return res.status(400).json({ success: false, message: "잘못된 요청입니다." });
    }

    try {
        const vote = await CVote.findOne({ where: { c_number } });
        if (!vote) {
            return res.status(404).json({ success: false, message: "투표를 찾을 수 없습니다." });
        }
        const currentDate = new Date();
        if (currentDate >= vote.c_deletedate) {
            return res.status(403).json({ success: false, message: "투표가 종료되었습니다." });
        }
        if (vote.u_id === currentUserId) {
            return res.status(403).json({ success: false, message: "자신이 생성한 투표에 좋아요/싫어요를 누를 수 없습니다." });
        }
        const existingVoteAction = await c_v_notdup.findOne({
            where: {
                u_id: vote.u_id ,       
                c_number: vote.c_number,
                vote_id: currentUserId,
            },
        });
        if (existingVoteAction) {
            return res.status(403).json({ success: false, message: "이미 투표하셨습니다." });
        }
        await c_v_notdup.create({
            u_id: vote.u_id,            
            c_number: vote.c_number,       
            vote_id: currentUserId, // 액션 (good 또는 bad)
        });
        if (action === 'good') {
            vote.c_good += 1;
        } else if (action === 'bad') {
            vote.c_bad += 1;
        }

        await vote.save();
        res.json({ success: true, vote });
    } catch (error) {
        console.error("Error updating vote:", error);
        res.status(500).json({ success: false, message: "투표 업데이트 실패" });
    }
};
exports.deleteVote = async (req, res) => {
    const { c_number } = req.params;
    const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기

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
            },
        });
    } catch (error) {
        console.error("Error fetching vote details:", error);
        res.status(500).json({ success: false, message: "투표 정보를 가져오는데 실패했습니다." });
    }
};