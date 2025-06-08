const db = require('../config/db');
const { QueryTypes } = require('sequelize');
const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');

router.get('/items', shopController.getShopItems);
router.post('/buy', shopController.buyItem);
router.get('/points/:user_id', shopController.getUserPoints);

module.exports = router;
