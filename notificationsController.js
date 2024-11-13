const db = require('../config/db');
const logger = require('../logger');

// 읽지 않은 알림 조회
exports.getUnreadNotifications = (req, res) => {
  const userId = req.user.id;

  db.query('SELECT * FROM notifications WHERE user_id = ? AND is_read = FALSE', [userId], (err, results) => {
    if (err) {
      logger.error("Error fetching unread notifications:", err);
      return res.status(500).send("Error fetching unread notifications");
    }
    res.json(results);
  });
};

// 새 알림 추가 (예: 미션 부여 시)
exports.addNotification = (userId, message) => {
  return new Promise((resolve, reject) => {
    db.query('INSERT INTO notifications (user_id, message, is_read) VALUES (?, ?, FALSE)', [userId, message], (err, result) => {
      if (err) {
        logger.error("Error adding notification:", err);
        reject("Error adding notification");
      } else {
        resolve("Notification added successfully");
      }
    });
  });
};

// 알림 읽음 처리
exports.markAsRead = (req, res) => {
  const userId = req.user.id;
  const notificationId = req.params.id;

  db.query('UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?', [notificationId, userId], (err, result) => {
    if (err) {
      logger.error("Error marking notification as read:", err);
      return res.status(500).send("Error marking notification as read");
    }

    if (result.affectedRows === 0) {
      return res.status(404).send("Notification not found or already read");
    }

    res.send("Notification marked as read");
  });
};

// 모든 알림 읽음 처리
exports.markAllAsRead = (req, res) => {
  const userId = req.user.id;

  db.query('UPDATE notifications SET is_read = TRUE WHERE user_id = ?', [userId], (err, result) => {
    if (err) {
      logger.error("Error marking all notifications as read:", err);
      return res.status(500).send("Error marking all notifications as read");
    }

    res.send("All notifications marked as read");
  });
};