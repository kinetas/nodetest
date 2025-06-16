const db = require('../config/db');
const { QueryTypes } = require('sequelize');
const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

router.get('/items', shopController.getShopItems);
router.post('/buy', shopController.buyItem);
router.get('/points', shopController.getUserPoints);
router.get('/my-items', shopController.getMyItems);
router.post('/apply-item', shopController.applyItem);

module.exports = router;
