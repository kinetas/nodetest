const NotificationLog = require('../models/notificationModel');
/*
// 클라이언트에서 전달받은 토큰 DB에 저장
const saveToken = async (req, res) => {
    const { userId, token } = req.body;

    // 필수 필드 확인
    if (!userId || !token) {
        return res.status(400).json({ error: 'Missing userId or token' });
    }

    try {
        // 토큰 저장 또는 업데이트
        await db.query(
            'INSERT INTO user_tokens (user_id, token) VALUES (?, ?) ON DUPLICATE KEY UPDATE token = ?',
            [userId, token, token]
        );
        res.status(200).json({ message: 'Token saved successfully' });
    } catch (error) {
        console.error('Error saving token:', error);
        res.status(500).json({ error: 'Failed to save token' });
    }
};
*/
/// 기본 알림 전송 함수
const sendNotification = async (userId, title, body = {}) => {
    const [rows] = await db.query('SELECT token FROM user WHERE user_id = ?', [userId]);
    if (rows.length === 0) {
        throw new Error('No token found for user');
    }
    const token = rows[0].token;
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
    console.log('Request Headers:', req.headers); // 요청 헤더 출력
    console.log('Request Received at Controller:', req.body); // 요청 데이터 확인
    const { userId, token, title, body } = req.body;

    if (!userId || !token || !title || !body) {
        console.error('Missing Required Fields:', req.body); // 누락된 데이터 확인
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
    const title = '친구 요청 수락 알림';
    const body = `${senderId}님이 친구 요청을 수락하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 생성 알림 함수
const sendMissionCreateNotification = async (token, senderId, userId) => {
    const title = '미션 생성 알림';
    const body = `${senderId}님이 미션을 생성하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 인증 요청 알림 함수
const sendRequestMissionApprovalNotification = async (token, senderId, userId) => {
    const title = '미션 인증 요청 알림';
    const body = `${senderId}님이 미션 인증을 요청하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 성공 알림 함수
const sendMissionSuccessNotification = async (token, senderId, userId) => {
    const title = '미션 성공 알림';
    const body = `${senderId}님이 미션을 성공 처리하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 실패 알림 함수
const sendMissionFailureNotification = async (token, senderId, userId) => {
    const title = '미션 실패 알림';
    const body = `${senderId}님이 미션을 실패 처리하였습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 마감기한 임박 (10분) 알림 함수
const sendMissionDeadlineTenMinutesNotification = async (token, userId, missionTitle) => {
    const title = '마감 기한 임박 알림';
    const body = `${missionTitle} 미션의 마감기한이 10분 남았습니다.`;
    return await sendNotification(userId, token, title, body);
};

// 미션 마감기한 경과 알림 함수
const sendMissionDeadlineNotification = async (token, userId, missionTitle) => {
    const title = '마감 기한 경과 알림';
    const body = `${missionTitle} 미션의 마감기한이 지났습니다.`;
    return await sendNotification(userId, token, title, body);
};

//메시지 수신 알림
const sendMessageNotification = async (senderId, receiverId, messageContent) => {
    const title = '새로운 메시지 도착';
    const body = `${senderId}님이 보낸 메시지: "${messageContent}"`;

    try {
        return await sendNotification(receiverId, title, body);
    } catch (error) {
        console.error(`Failed to send message notification to user ${receiverId}:`, error.message);
        throw error;
    }
};
module.exports = {
    sendNotificationController,
    sendFriendRequestNotification,
    sendFriendAcceptNotification,
    sendMissionCreateNotification,
    sendMissionSuccessNotification,
    sendMissionFailureNotification,
    sendRequestMissionApprovalNotification,
    sendMissionDeadlineTenMinutesNotification,
    sendMissionDeadlineNotification,
    sendMessageNotification,
};