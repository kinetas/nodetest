const db = require('../config/db');
const { QueryTypes } = require('sequelize');

//리그 배치
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

// 본인이 속한 리그 불러오기
exports.getLeagueDetail = async (req, res) => {
  const user_id = req.params.user_id;

  if (!user_id) {
    return res.status(400).json({ message: 'user_id가 없습니다.' });
  }

  try {
    // 1. 본인의 리그 확인
    const [userStatus] = await db.query(
      `SELECT league_id FROM user_league_status WHERE user_id = :user_id`,
      { replacements: { user_id }, type: QueryTypes.SELECT }
    );

    if (!userStatus) {
      return res.status(404).json({ message: '해당 유저의 리그 정보가 없습니다.' });
    }

    const league_id = userStatus.league_id;

    // 2. 리그 상세 정보 (tier, name)
    const [leagueInfo] = await db.query(
      `SELECT tier, name FROM leagues WHERE league_id = :league_id`,
      { replacements: { league_id }, type: QueryTypes.SELECT }
    );

    // 3. 같은 리그에 속한 유저들 LP 순위
    const members = await db.query(
      `SELECT user_id, lp FROM user_league_status WHERE league_id = :league_id ORDER BY lp DESC`,
      { replacements: { league_id }, type: QueryTypes.SELECT }
    );

    // 4. 순위 매기기
    const users = members.map((user, index) => ({
      user_id: user.user_id,
      lp: user.lp,
      rank: index + 1
    }));

    return res.status(200).json({
      user_id,
      league_id,
      tier: leagueInfo.tier,
      league_name: leagueInfo.name,
      users
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류', error: err.message });
  }
};
//미션수행시 lp 지급 api 
exports.updateLpOnMission = async (req, res) => {
  const { user_id, success } = req.body;

  if (!user_id || success === undefined) {
    return res.status(400).json({ message: 'user_id와 success 값이 필요합니다.' });
  }

  const lpToAdd = success ? 20 : 5;

  try {
    // LP 증가 처리
    const [result] = await db.query(
      `UPDATE user_league_status 
       SET lp = lp + :lpToAdd 
       WHERE user_id = :user_id`,
      {
        replacements: { lpToAdd, user_id },
        type: QueryTypes.UPDATE
      }
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: '해당 유저의 리그 정보가 없습니다.' });
    }

    return res.status(200).json({ message: `LP가 ${lpToAdd}만큼 증가했습니다.` });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '서버 오류', error: err.message });
  }
};