const db = require('../config/db'); // DB 연결 모듈

exports.assignInitialLeague = async (req, res) => {
const { user_id } = req.body;

  try {
    // 1. 이미 배정된 유저인지 확인
    const [existing] = await db.query(
      `SELECT * FROM user_league_status WHERE user_id = ?`,
      [user_id]
    );

    if (existing.length > 0) {
      return res.status(200).json({
        message: '이미 리그에 배정된 사용자입니다.',
        data: existing[0]
      });
    }

    // 2. 전체 리그 목록 조회
    const [leagues] = await db.query(`SELECT league_id FROM leagues`);
    if (leagues.length === 0) {
      return res.status(500).json({ message: '리그 정보가 없습니다.' });
    }

    // 3. 무작위 리그 선택
    const randomIndex = Math.floor(Math.random() * leagues.length);
    const selectedLeague = leagues[randomIndex].league_id;

    // 4. 사용자 리그 상태 등록
    await db.query(
      `INSERT INTO user_league_status (user_id, league_id, lp) VALUES (?, ?, 0)`,
      [user_id, selectedLeague]
    );

    return res.status(201).json({
      message: '리그가 성공적으로 배정되었습니다.',
      data: {
        user_id,
        league_id: selectedLeague,
        lp: 0
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류', error: err.message });
  }
};