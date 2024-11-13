const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notificationsController');
const authenticateToken = require('../auth');

router.get('/unread', authenticateToken, notificationsController.getUnreadNotifications);

module.exports = router;