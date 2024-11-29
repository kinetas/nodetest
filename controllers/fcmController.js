const admin = require('firebase-admin');
const path = require('path');
const NotificationLog = require('../models/notificationModel');

// 서비스 계정 키 파일 경로
const serviceAccount = require(path.join(__dirname, '../config/capdesign-d9d41-firebase-adminsdk-b83nr-9d02a2d120.json'));

// Firebase Admin SDK 초기화
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});


// 기본 알림 전송 함수
const sendNotification = async (token, payload, userId) => {
    try {
        const response = await admin.messaging().send({
            token: token,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data || {},
        });

        console.log('Successfully sent message:', response);

        // 성공 시 알림 로그 저장
        await NotificationLog.create({
            userId,
            title: payload.title,
            body: payload.body,
            status: 'success',
            timestamp: new Date(),
        });
    } catch (error) {
        console.error('Error sending message:', error);

        // 실패 시 알림 로그 저장
        await NotificationLog.create({
            userId,
            title: payload.title,
            body: payload.body,
            status: 'failed',
            errorMessage: error.message,
            timestamp: new Date(),
        });
    }
};

// 친구 요청 알림 함수
const sendFriendRequestNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '친구 요청',
        body: `${senderId}님이 친구 요청을 보냈습니다.`,
    }, userId);
};

// 친구 요청 수락 알림 함수
const sendFriendAcceptNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '친구 요청 수락',
        body: `${senderId}님이 친구 요청을 수락했습니다.`,
    }, userId);
};

// 친구 요청 거절 알림 함수
const sendFriendRejectNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '친구 요청 거절',
        body: `${senderId}님이 친구 요청을 거절했습니다.`,
    }, userId);
};

// 미션 생성 알림 함수
const sendMissionCreateNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '미션 생성 완료',
        body: `${senderId}님이 미션을 생성하였습니다.`,
    }, userId);
};

// 미션 성공 알림 함수
const sendMissionSuccessNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '미션 성공',
        body: `${senderId}님이 미션을 성공하였습니다.`,
    }, userId);
};

// 미션 실패 알림 함수
const sendMissionFailureNotification = async (token, senderId, userId) => {
    await sendNotification(token, {
        title: '미션 실패',
        body: `${senderId}님이 미션을 실패하였습니다.`,
    }, userId);
};

module.exports = {
    sendNotification,
    sendFriendRequestNotification,
    sendFriendAcceptNotification,
    sendFriendRejectNotification,
    sendMissionCreateNotification,
    sendMissionSuccessNotification,
    sendMissionFailureNotification,
};