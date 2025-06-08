const db = require('../config/db');
const { QueryTypes } = require('sequelize');

exports.getShopItems = async (req, res) => {
  try {
    const items = await db.query(`SELECT * FROM shop_items`, {
      type: QueryTypes.SELECT,
    });
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: '아이템 조회 실패' });
  }
};

exports.getUserPoints = async (req, res) => {
  const { user_id } = req.params;
  try {
    const result = await db.query(
      `SELECT points FROM user_points WHERE user_id = :user_id`,
      {
        replacements: { user_id },
        type: QueryTypes.SELECT,
      }
    );
    const points = result[0]?.points || 0;
    res.json({ points });
  } catch (err) {
    res.status(500).json({ error: '포인트 조회 실패' });
  }
};

exports.buyItem = async (req, res) => {
  const { user_id, item_id } = req.body;

  try {
    const [item] = await db.query(
      `SELECT * FROM shop_items WHERE item_id = :item_id`,
      {
        replacements: { item_id },
        type: QueryTypes.SELECT,
      }
    );

    if (!item) return res.status(404).json({ error: '아이템이 존재하지 않습니다' });

    const [userPoint] = await db.query(
      `SELECT points FROM user_points WHERE user_id = :user_id`,
      {
        replacements: { user_id },
        type: QueryTypes.SELECT,
      }
    );

    const currentPoints = userPoint?.points ?? 0;

    if (currentPoints < item.price)
      return res.status(400).json({ error: '포인트가 부족합니다' });

    // 중복 구매 방지
    const [existing] = await db.query(
      `SELECT * FROM user_items WHERE user_id = :user_id AND item_id = :item_id`,
      {
        replacements: { user_id, item_id },
        type: QueryTypes.SELECT,
      }
    );

    if (existing) return res.status(400).json({ error: '이미 구매한 아이템입니다' });

    // 포인트 차감
    await db.query(
      `UPDATE user_points SET points = points - :price WHERE user_id = :user_id`,
      {
        replacements: { price: item.price, user_id },
        type: QueryTypes.UPDATE,
      }
    );

    // 아이템 지급
    await db.query(
      `INSERT INTO user_items (user_id, item_id) VALUES (:user_id, :item_id)`,
      {
        replacements: { user_id, item_id },
        type: QueryTypes.INSERT,
      }
    );
    
    res.json({ message: '아이템 구매 성공' });
  } catch (err) {
    res.status(500).json({ error: '구매 처리 실패' });
  }
};
