const express = require('express');
const router = express.Router();
const leagueController = require('../controllers/leagueController');
//배치 api
router.post('/league/assign', leagueController.assignInitialLeague);
//본인 리그 조회
router.get('/detail/:user_id', leagueController.getLeagueDetail);
module.exports = router;