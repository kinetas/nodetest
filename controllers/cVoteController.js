const { Op } = require('sequelize');
const { sequelize } = require('../models/comunity_voteModel'); // sequelize 인스턴스를 models에서 가져옵니다.
const CVote = require('../models/comunity_voteModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');


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

// 투표 생성
exports.createVote = async (req, res) => {
    const { c_title, c_contents } = req.body;
    const u_id = req.session.user.id; // 세션에서 u_id 가져오기, 기본 값 설정

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
            c_deletedate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000) // 현재 날짜 + 3일
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

    if (!c_number || !['good', 'bad'].includes(action)) {
        return res.status(400).json({ success: false, message: "잘못된 요청입니다." });
    }

    try {
        const vote = await CVote.findOne({ where: { c_number } });
        if (!vote) {
            return res.status(404).json({ success: false, message: "투표를 찾을 수 없습니다." });
        }

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
// 본인 투표율 주작할수 있는 문제 수정
// 추후 아이디나 타이틀 같은 걸 누르면 안의 내용물이 뜨고 그안에서 good,bad를 올릴 수 있도록 수정
// 인당 투표수 한번으로 제한