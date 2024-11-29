const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notificationsController');
const NotificationLog = require('../models/notificationModel');
const authenticateToken = require('../auth');

router.get('/unread', authenticateToken, notificationsController.getUnreadNotifications);

// 알림 읽음 처리 라우트 추가
router.post('/notifications/read/:id', async (req, res) => {
    try {
    const notificationId = req.params.id;
    await NotificationLog.update({ readStatus: true }, { where: { id: notificationId } });

    res.status(200).json({ message: '알림이 읽음 처리되었습니다.' });
    } catch (error) {
    console.error('Error updating notification read status:', error);
    res.status(500).json({ message: '알림 읽음 처리 중 오류가 발생했습니다.' });
    }
});
module.exports = router;