const express = require('express');
const router = express.Router();
const leagueController = require('../controllers/leagueController');

router.post('/league/assign', leagueController.assignInitialLeague);

module.exports = router;