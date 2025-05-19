require('dotenv').config();
const db = require('../config/db');

const { runWeeklyLeagueEvaluation } = require('./leagueScheduler');
runWeeklyLeagueEvaluation();