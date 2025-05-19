const db = require('../config/db');
const { QueryTypes } = require('sequelize');

const { runWeeklyLeagueEvaluation } = require('./leagueScheduler');
runWeeklyLeagueEvaluation();