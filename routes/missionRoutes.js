// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions } = require('../controllers/missionController');
const requireAuth = require('../middleware/authMiddleware'); // requireAuth 미들웨어 경로 확인

// 미션 리스트 반환 라우트
router.get('/missions', requireAuth, getUserMissions);

// // 미션 생성 페이지로 이동
// router.get('/missioncreate', requireAuth, (req, res) => {
//     res.sendFile(path.join(__dirname, '../public', 'missioncreate.html'));
// });

// // 미션 생성 요청 처리
// router.post('/missioncreate', requireAuth, createMission);

// 미션 생성 요청 처리
router.post('/missioncreate', requireAuth, createMission);

module.exports = router;