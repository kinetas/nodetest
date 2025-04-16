const express = require('express');
const router = express.Router();
const { createCommunityMission, acceptCommunityMission, deleteCommunityMission } = require('../controllers/c_missionController');
// const requireAuth = require('../middleware/authMiddleware'); // 인증 미들웨어
const loginRequired = require('../middleware/loginRequired'); // JWT 기반 인증 미들웨어
const CRoom = require('../models/comunity_roomModel');

// router.post('/create', requireAuth, createCommunityMission);
// router.post('/accept', requireAuth, acceptCommunityMission);
// router.delete('/delete', requireAuth, deleteCommunityMission);

router.post('/create', loginRequired, createCommunityMission);
router.post('/accept', loginRequired, acceptCommunityMission);
router.delete('/delete', loginRequired, deleteCommunityMission);

// router.get('/list', requireAuth, async (req, res) => {
router.get('/list', loginRequired, async (req, res) => {
    try {
        const missions = await CRoom.findAll({
            order: [['deadline', 'ASC']], // deadline 기준 오름차순 정렬
        }); // 모든 커뮤니티 미션 가져오기
        res.json({ missions });
    } catch (error) {
        console.error('커뮤니티 미션 리스트 오류:', error);
        res.status(500).json({ message: '커뮤니티 미션 리스트를 불러오는 중 오류가 발생했습니다.' });
    }
});

module.exports = router;