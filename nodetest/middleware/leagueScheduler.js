const db = require('../config/db');
const { QueryTypes } = require('sequelize');

async function runWeeklyLeagueEvaluation() {
  try {
    // 전체 리그 목록
    const leagues = await db.query(
      `SELECT * FROM leagues ORDER BY level ASC`,
      { type: QueryTypes.SELECT }
    );

    for (const league of leagues) {
      const leagueId = league.league_id;
      const tier = league.tier;
      const level = league.level;

      // 현재 리그의 유저들 LP 순 정렬
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
      const bottomCount = tier === 'bronze' ? 0 : Math.floor(total * 0.1); // 브론즈는 강등 없음

      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);
      const weekStartStr = weekStart.toISOString().split('T')[0];
      const weekEndStr = now.toISOString().split('T')[0];

      for (let i = 0; i < users.length; i++) {
        const user = users[i];

        // 기록 백업
        await db.query(
          `INSERT INTO weekly_lp_history (user_id, week_start, week_end, league_id, lp)
           VALUES (:user_id, :week_start, :week_end, :league_id, :lp)`,
          {
            replacements: {
              user_id: user.user_id,
              week_start: weekStartStr,
              week_end: weekEndStr,
              league_id: leagueId,
              lp: user.lp
            },
            type: QueryTypes.INSERT
          }
        );

        // 승급
        if (i < topCount) {
          const upper = leagues.find(l => l.level === level + 1);
          if (upper) {
            // 같은 tier 중 무작위 선택 가능하게 하려면 여기서 upper.tier에 대해 SELECT
            const upperLeagues = await db.query(
              `SELECT league_id FROM leagues WHERE level = :level`,
              {
                replacements: { level: upper.level },
                type: QueryTypes.SELECT
              }
            );
            const rand = Math.floor(Math.random() * upperLeagues.length);
            const nextLeagueId = upperLeagues[rand].league_id;

            await db.query(
              `UPDATE user_league_status SET league_id = :next_league, lp = 0 WHERE user_id = :user_id`,
              {
                replacements: { next_league: nextLeagueId, user_id: user.user_id },
                type: QueryTypes.UPDATE
              }
            );

            // 포인트 지급 (예: 100pt)
            await db.query(
              `INSERT INTO user_points (user_id, points)
               VALUES (:user_id, 100)
               ON DUPLICATE KEY UPDATE points = points + 100`,
              {
                replacements: { user_id: user.user_id },
                type: QueryTypes.INSERT
              }
            );
          }
        }

        // 강등
        else if (i >= total - bottomCount && tier !== 'bronze') {
          const lower = leagues.find(l => l.level === level - 1);
          if (lower) {
            const lowerLeagues = await db.query(
              `SELECT league_id FROM leagues WHERE level = :level`,
              {
                replacements: { level: lower.level },
                type: QueryTypes.SELECT
              }
            );
            const rand = Math.floor(Math.random() * lowerLeagues.length);
            const prevLeagueId = lowerLeagues[rand].league_id;

            await db.query(
              `UPDATE user_league_status SET league_id = :prev_league, lp = 0 WHERE user_id = :user_id`,
              {
                replacements: { prev_league: prevLeagueId, user_id: user.user_id },
                type: QueryTypes.UPDATE
              }
            );
          }
        }

        // 잔류
        else {
          await db.query(
            `UPDATE user_league_status SET lp = 0 WHERE user_id = :user_id`,
            {
              replacements: { user_id: user.user_id },
              type: QueryTypes.UPDATE
            }
          );
        }
      }
    }

    console.log('✅ 주간 리그 정산 완료');
  } catch (err) {
    console.error('❌ 주간 리그 정산 실패:', err.message);
  }
}

module.exports = { runWeeklyLeagueEvaluation };