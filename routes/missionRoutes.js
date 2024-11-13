// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions, createMission, deleteMission } = require('../controllers/missionController');
const requireAuth = require('../middleware/authMiddleware'); // requireAuth 미들웨어 경로 확인

// 미션 리스트 반환 라우트
router.get('/missions', requireAuth, getUserMissions);

// 미션 생성 요청 처리
router.post('/missioncreate', requireAuth, createMission);

// 미션 삭제 요청 처리
router.delete('/missiondelete', requireAuth, deleteMission);

module.exports = router;