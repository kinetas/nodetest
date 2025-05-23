require('dotenv').config();
const db = require('../config/db');

console.log("✅ env 검사:", {
  DB: process.env.DATABASE_NAME,
  USER: process.env.DATABASE_USER,
  PASS: process.env.DATABASE_PASSWORD
});


const { runWeeklyLeagueEvaluation } = require('./leagueScheduler');
runWeeklyLeagueEvaluation();