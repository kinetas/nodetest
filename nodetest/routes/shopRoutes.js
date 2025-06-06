const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

router.get('/items', shopController.getShopItems);
router.post('/buy', shopController.buyItem);

module.exports = router;
