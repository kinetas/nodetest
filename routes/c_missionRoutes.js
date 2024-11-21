const express = require('express');
const router = express.Router();
const { createCommunityMission, acceptCommunityMission, deleteCommunityMission } = require('../controllers/c_missionController');
const requireAuth = require('../middleware/authMiddleware'); // 인증 미들웨어

router.post('/create', requireAuth, createCommunityMission);
router.post('/accept', requireAuth, acceptCommunityMission);
router.delete('/delete', requireAuth, deleteCommunityMission);

module.exports = router;