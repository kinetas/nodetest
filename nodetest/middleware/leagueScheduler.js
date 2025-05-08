const db = require('../config/db');
const { QueryTypes } = require('sequelize');

async function runWeeklyLeagueEvaluation() {
  try {
    const leagues = await db.query(
      `SELECT * FROM leagues ORDER BY level ASC`,
      { type: QueryTypes.SELECT }
    );

    // 정산 중 중복 처리 방지용
    const processedUsers = new Set();

    for (const league of leagues) {
      const leagueId = league.league_id;
      const tier = league.tier;
      const level = league.level;

      const users = await db.query(
        `SELECT user_id, lp FROM user_league_status WHERE league_id = :league_id ORDER BY lp DESC`,
        {
          replacements: { league_id: leagueId },
          type: QueryTypes.SELECT
        }
      );

      const total = users.length;
      if (total === 0) continue;

      const topCount = Math.floor(total * 0.4);
      const bottomCount = tier === 'bronze' ? 0 : Math.floor(total * 0.1);

      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);
      const weekStartStr = weekStart.toISOString().split('T')[0];
      const weekEndStr = now.toISOString().split('T')[0];

      for (let i = 0; i < users.length; i++) {
        const user = users[i];
        const userId = user.user_id;

        // 이미 리그 이동된 유저는 건너뜀
        if (processedUsers.has(userId)) continue;

        // 유저의 현재 리그 확인 (정산 도중 이동했을 수 있음)
        const [current] = await db.query(
          `SELECT league_id FROM user_league_status WHERE user_id = :user_id`,
          {
            replacements: { user_id: userId },
            type: QueryTypes.SELECT
          }
        );

        if (current.league_id !== leagueId) continue;

        // 1. 정산 기록 백업
        await db.query(
          `INSERT INTO weekly_lp_history (user_id, week_start, week_end, league_id, lp)
           VALUES (:user_id, :week_start, :week_end, :league_id, :lp)`,
          {
            replacements: {
              user_id: userId,
              week_start: weekStartStr,
              week_end: weekEndStr,
              league_id: leagueId,
              lp: user.lp
            },
            type: QueryTypes.INSERT
          }
        );

        // 2. 승급
        if (i < topCount) {
          const upperLeagues = leagues.filter(l => l.level === level + 1);
          if (upperLeagues.length > 0) {
            const nextLeague = upperLeagues[Math.floor(Math.random() * upperLeagues.length)];

            await db.query(
              `UPDATE user_league_status SET league_id = :next_league, lp = 0 WHERE user_id = :user_id`,
              {
                replacements: {
                  next_league: nextLeague.league_id,
                  user_id: userId
                },
                type: QueryTypes.UPDATE
              }
            );

            // 포인트 보상
            await db.query(
              `INSERT INTO user_points (user_id, points)
               VALUES (:user_id, 100)
               ON DUPLICATE KEY UPDATE points = points + 100`,
              {
                replacements: { user_id: userId },
                type: QueryTypes.INSERT
              }
            );
          }
        }

        // 3. 강등
        else if (i >= total - bottomCount && tier !== 'bronze') {
          const lowerLeagues = leagues.filter(l => l.level === level - 1);
          if (lowerLeagues.length > 0) {
            const prevLeague = lowerLeagues[Math.floor(Math.random() * lowerLeagues.length)];

            await db.query(
              `UPDATE user_league_status SET league_id = :prev_league, lp = 0 WHERE user_id = :user_id`,
              {
                replacements: {
                  prev_league: prevLeague.league_id,
                  user_id: userId
                },
                type: QueryTypes.UPDATE
              }
            );
          }
        }

        // 4. 잔류
        else {
          await db.query(
            `UPDATE user_league_status SET lp = 0 WHERE user_id = :user_id`,
            {
              replacements: { user_id: userId },
              type: QueryTypes.UPDATE
            }
          );
        }

        // 처리 완료 표시
        processedUsers.add(userId);
      }
    }

    console.log('✅ 주간 리그 정산 완료');
  } catch (err) {
    console.error('❌ 주간 리그 정산 실패:', err.message);
  }
}

module.exports = { runWeeklyLeagueEvaluation };
