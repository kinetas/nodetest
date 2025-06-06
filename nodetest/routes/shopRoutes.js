const db = require('../config/db');
const { QueryTypes } = require('sequelize');
const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

router.get('/items', shopController.getShopItems);
router.post('/buy', shopController.buyItem);
router.get('/points/:user_id', async (req, res) => {
  const { user_id } = req.params;
  try {
    const result = await db.query(
      'SELECT points FROM user_points WHERE user_id = ?',
      { replacements: [user_id], type: QueryTypes.SELECT }
    );
    const points = result[0]?.points || 0;
    res.json({ points });
  } catch (err) {
    res.status(500).json({ error: 'DB 조회 실패' });
  }
});
module.exports = router;
