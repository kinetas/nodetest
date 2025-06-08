const db = require('../config/db');
const { QueryTypes } = require('sequelize');
const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

router.get('/items', shopController.getShopItems);
router.post('/buy', shopController.buyItem);
router.get('/points/:user_id', shopController.getUserPoints);
router.get('/my-items/:user_id', shopController.getMyItems);
router.post('/apply-item', shopController.applyItem);

module.exports = router;
