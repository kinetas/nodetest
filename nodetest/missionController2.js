const db = require('../config/db');
const admin = require('../firebaseAdmin');
const notificationsController = require('./notificationsController'); // 알림 컨트롤러 가져오기

// 미션 부여 함수
exports.assignMission = (io, socket, { roomId, missionDetails, assignedTo }) => {
  // DB에 미션을 저장
  db.query('INSERT INTO missions (room_id, details, assigned_to) VALUES (?, ?, ?)', [roomId, missionDetails, assignedTo], (err, result) => {
    if (err) {
      console.error('Error assigning mission:', err);
      return;
    }

    // 미션이 성공적으로 저장되면 알림을 생성
    const notificationMessage = `새로운 미션이 부여되었습니다: ${missionDetails}`;
    notificationsController.addNotification(assignedTo, notificationMessage)
      .then((message) => console.log(message))  // 성공 메시지 출력
      .catch((error) => console.error(error));  // 에러 출력

    // 사용자에게 FCM 푸시 알림 전송
    db.query('SELECT fcm_token FROM users WHERE id = ?', [assignedTo], (err, results) => {
      if (err || results.length === 0) {
        console.error('FCM token not found');
        return;
      }

      const userToken = results[0].fcm_token;
      const message = {
        notification: { title: '새로운 미션 알림', body: missionDetails },
        token: userToken
      };

      admin.messaging().send(message)
        .then(response => console.log("FCM Notification sent successfully:", response))
        .catch(error => console.error("Error sending FCM notification:", error));
    });

    // 채팅방에 미션 부여 이벤트 알림 전송
    io.to(roomId).emit('missionAssigned', { missionDetails, assignedTo });
  });
};