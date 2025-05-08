const express = require('express');
const router = express.Router();
const { createCommunityMission, acceptCommunityMission, deleteCommunityMission, getCommunityMission } = require('../controllers/c_missionController');
const loginRequired = require('../middleware/loginRequired'); // JWT 기반 인증 미들웨어

router.post('/create', loginRequired, createCommunityMission);
router.post('/accept', loginRequired, acceptCommunityMission);
router.delete('/delete', loginRequired, deleteCommunityMission);

router.get('/list', loginRequired, getCommunityMission);

router.post('/createGeneralCommunity', loginRequired, createCommunity);
router.get('/printGeneralCommunityList', loginRequired, printGeneralCommunity);
router.post('/recommendCommunity', loginRequired, recommendCommunity);

module.exports = router;