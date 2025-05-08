const db = require('../config/db');
const { QueryTypes } = require('sequelize');

exports.assignInitialLeague = async (req, res) => {
  const user_id = req.body.user_id;

  if (!user_id) {
    return res.status(400).json({ message: 'user_id가 요청 본문에 없습니다.' });
  }

  try {
    // 이미 배정된 유저인지 확인
    const [existing] = await db.query(
      `SELECT * FROM user_league_status WHERE user_id = :user_id`,
      {
        replacements: { user_id },
        type: QueryTypes.SELECT
      }
    );

    if (existing) {
      return res.status(200).json({
        message: '이미 리그에 배정된 사용자입니다.',
        data: existing
      });
    }

    // 브론즈 tier 리그 중 하나 무작위 선택
    const bronzeLeagues = await db.query(
      `SELECT league_id FROM leagues WHERE tier = 'bronze'`,
      { type: QueryTypes.SELECT }
    );

    if (!bronzeLeagues || bronzeLeagues.length === 0) {
      return res.status(500).json({ message: '브론즈 리그가 없습니다.' });
    }

    const randomIndex = Math.floor(Math.random() * bronzeLeagues.length);
    const selectedLeague = bronzeLeagues[randomIndex].league_id;

    // user_league_status 테이블에 배정
    await db.query(
      `INSERT INTO user_league_status (user_id, league_id, lp) VALUES (:user_id, :league_id, 0)`,
      {
        replacements: { user_id, league_id: selectedLeague },
        type: QueryTypes.INSERT
      }
    );

    return res.status(201).json({
      message: '브론즈 리그에 성공적으로 배정되었습니다.',
      data: {
        user_id,
        league_id: selectedLeague,
        lp:0
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류', error: err.message });
  }
};