const NotificationLog = require('../models/notificationModel');

/// 기본 알림 전송 함수
const sendNotification = async (userId, token, title, body = {}) => {
    const message = {
        notification: { title, body }, // 알림 제목과 내용
        token, // FCM 토큰
    };

    try {
        // Firebase를 통해 알림 전송
        const response = await admin.messaging().send(message);

        // 성공 시 로그 저장
        await NotificationLog.create({
            userId,
            title,
            body,
            status: 'success',
            timestamp: new Date(),
        });

        console.log(`Notification sent to user ${userId}:`, response);
        return response;
    } catch (error) {
        console.error(`Failed to send notification to user ${userId}:`, error.message);

        // 실패 시 로그 저장
        await NotificationLog.create({
            userId,
            title,
            body,
            status: 'failed',
            errorMessage: error.message,
            timestamp: new Date(),
        });

        throw error;
    }
};
// API 컨트롤러 함수
const sendNotificationController = async (req, res) => {
    const { userId, token, title, body } = req.body;

    if (!userId || !token || !title || !body) {
        return res.status(400).json({ error: 'Missing required fields.' });
    }

    try {
        const response = await sendNotification(userId, token, title, body);
        res.status(200).json({ message: 'Notification sent successfully.', response });
    } catch (error) {
        res.status(500).json({ error: 'Failed to send notification.' });
    }
};
// 친구 요청 알림 함수
const sendFriendRequestNotification = async (token, senderId, userId) => {
    const title = '친구 요청 알림';
    const body = `${senderId}님이 친구 요청을 보냈습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 친구 요청 수락 알림 함수
const sendFriendAcceptNotification = async (token, senderId, userId) => {
    const title = '미션 수락 알림';
    const body = `${senderId}님이 미션을 수락하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 생성 알림 함수
const sendMissionCreateNotification = async (token, senderId, userId) => {
    const title = '미션 생성 알림';
    const body = `${senderId}님이 미션을 생성하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 성공 알림 함수
const sendMissionSuccessNotification = async (token, senderId, userId) => {
    const title = '미션 성공 알림';
    const body = `${senderId}님이 미션을 성공하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 실패 알림 함수
const sendMissionFailureNotification = async (token, senderId, userId) => {
    const title = '미션 실패 알림';
    const body = `${senderId}님이 미션을 실패하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

module.exports = {
    sendNotificationController,
    sendFriendRequestNotification,
    sendFriendAcceptNotification,
    sendMissionCreateNotification,
    sendMissionSuccessNotification,
    sendMissionFailureNotification,
};