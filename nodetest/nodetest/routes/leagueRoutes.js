const express = require('express');
const router = express.Router();
const leagueController = require('../controllers/leagueController');
//배치 api
router.post('/assign', leagueController.assignInitialLeague);
//본인 리그 조회 api
router.get('/detail/:user_id', leagueController.getLeagueDetail);
//lp 지급 api
router.post('/mission-lp', leagueController.updateLpOnMission);
module.exports = router;