const db = require('../config/db');

// 매주 실행할 함수
async function runWeeklyLeagueEvaluation() {
try {
    // 전체 리그를 LP 순으로 조회
    const [leagues] = await db.query(`SELECT * FROM leagues ORDER BY level ASC`);

    for (let i = 0; i < leagues.length; i++) {
      const currentLeague = leagues[i];
      const [users] = await db.query(
        `SELECT * FROM user_league_status WHERE league_id = ? ORDER BY lp DESC`,
        [currentLeague.league_id]
      );

      const total = users.length;
      if (total === 0) continue;

      const topCount = Math.floor(total * 0.4);
      const bottomCount = Math.floor(total * 0.1);

      // 리그 경계 확인
      const upperLeague = leagues[i + 1] ? leagues[i + 1].league_id : null;
      const lowerLeague = leagues[i - 1] ? leagues[i - 1].league_id : null;

      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - 7);
      const weekEnd = now.toISOString().split('T')[0];

      for (let idx = 0; idx < users.length; idx++) {
        const user = users[idx];

        // 이전 기록 백업
        await db.query(
          `INSERT INTO weekly_lp_history (user_id, week_start, week_end, league_id, lp)
           VALUES (?, ?, ?, ?, ?)`,
          [user.user_id, weekStart, weekEnd, user.league_id, user.lp]
        );

        // 승급
        if (idx < topCount && upperLeague) {
          await db.query(
            `UPDATE user_league_status SET league_id = ?, lp = 0 WHERE user_id = ?`,
            [upperLeague, user.user_id]
          );
          await db.query(
            `INSERT INTO user_points (user_id, points) VALUES (?, ?) ON DUPLICATE KEY UPDATE points = points + ?`,
            [user.user_id, 100, 100]
          );
        }

        // 강등
        else if (idx >= total - bottomCount && lowerLeague) {
          await db.query(
            `UPDATE user_league_status SET league_id = ?, lp = 0 WHERE user_id = ?`,
            [lowerLeague, user.user_id]
          );
        }

        // 잔류
        else {
          await db.query(
            `UPDATE user_league_status SET lp = 0 WHERE user_id = ?`,
            [user.user_id]
          );
        }
      }
    }

    console.log('[리그 정산 완료]');

  } catch (err) {
    console.error('리그 정산 실패:', err);
  }
}

module.exports = { runWeeklyLeagueEvaluation };