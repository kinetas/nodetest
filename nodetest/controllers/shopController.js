const db = require('../config/db');
const { QueryTypes } = require('sequelize');

//상점 아이템 조회
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


//보유 포인트 조회
exports.getUserPoints = async (req, res) => {
  const user_id = req.query.user_id;
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

//내가 가진 아이템 전체 조회
exports.getMyItems = async (req, res) => {
  const user_id = req.query.user_id;

  try {
    const items = await db.query(
      `SELECT s.item_id, s.name, s.description, s.image_url, s.model_file, s.item_type
       FROM user_items ui
       JOIN shop_items s ON ui.item_id = s.item_id
       WHERE ui.user_id = :user_id`,
      {
        replacements: { user_id },
        type: QueryTypes.SELECT,
      }
    );

    const [selected] = await db.query(
      `SELECT selected_item_id FROM user WHERE u_id = :user_id`,
      {
        replacements: { user_id },
        type: QueryTypes.SELECT,
      }
    );

    res.json({
      items,
      selected_item_id: selected?.selected_item_id ?? null,
    });
  } catch (err) {
    res.status(500).json({ error: '아이템 정보 조회 실패', detail: err.message });
  }
};

//아이템 구매
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

// 아이템 적용
exports.applyItem = async (req, res) => {
  const { user_id, item_id } = req.body;

  try {
    // 해당 아이템이 사용자의 아이템인지 확인
    const [check] = await db.query(
      `SELECT * FROM user_items WHERE user_id = :user_id AND item_id = :item_id`,
      {
        replacements: { user_id, item_id },
        type: QueryTypes.SELECT
      }
    );

    if (!check) {
      return res.status(403).json({ message: '해당 아이템을 보유하고 있지 않습니다.' });
    }

    await db.query(
      `UPDATE user SET selected_item_id = :item_id WHERE u_id = :user_id`,
      {
        replacements: { item_id, user_id },
        type: QueryTypes.UPDATE
      }
    );

    res.json({ message: '아이템이 적용되었습니다.' });
  } catch (err) {
    res.status(500).json({ message: '아이템 적용 실패', error: err.message });
  }
};
