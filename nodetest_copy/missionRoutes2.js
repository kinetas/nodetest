const express = require('express');
const router = express.Router();
const missionController = require('../controllers/missionController');
const authenticateToken = require('../auth');

// 미션 부여
router.post('/assign-mission', authenticateToken, missionController.assignMission);

// 미션 완료
router.post('/complete-mission', authenticateToken, missionController.completeMission);

module.exports = router;