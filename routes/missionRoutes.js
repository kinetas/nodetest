// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions, createMission, deleteMission, successMission, failureMission, printRoomMission  } = require('../controllers/missionController');
const requireAuth = require('../middleware/authMiddleware'); // requireAuth 미들웨어 경로 확인

// 미션 리스트 반환 라우트
router.get('/missions', requireAuth, getUserMissions);

// 자신이 수행해야 할 미션
router.get('/missions/assigned', requireAuth, getAssignedMissions);

// 자신이 부여한 미션
router.get('/missions/created', requireAuth, getCreatedMissions);

// 미션 생성 요청 처리
router.post('/missioncreate', requireAuth, createMission);

// 미션 삭제 요청 처리
router.delete('/missiondelete', requireAuth, deleteMission);

// 미션 성공 및 실패 요청 처리 라우트
router.post('/successMission', requireAuth, successMission);
router.post('/failureMission', requireAuth, failureMission);

// 방 미션 출력 라우트
router.post('/printRoomMission', requireAuth, printRoomMission);

module.exports = router;