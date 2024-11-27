const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin 초기화 비밀키 발급받고 저장해야됨
const serviceAccount = require(path.join(__dirname, 'path/to/serviceAccountKey.json'));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// 기본 알림 전송 함수
const sendNotification = (token, payload) => {
    return admin.messaging().send({
        token: token,
        notification: {
            title: payload.title,
            body: payload.body,
        },
        data: payload.data || {},
    }).then(response => {
        console.log('Successfully sent message:', response);
    }).catch(error => {
        console.error('Error sending message:', error);
    });
};

// 친구 요청 알림 함수
const sendFriendRequestNotification = async (token, senderId) => {
    await sendNotification(token, {
        title: '친구 요청',
        body: `${senderId}님이 친구 요청을 보냈습니다.`,
    });
};

// 친구 요청 수락 알림 함수
const sendFriendAcceptNotification = async (token, senderId) => {
    await sendNotification(token, {
        title: '친구 요청 수락',
        body: `${senderId}님이 친구 요청을 수락했습니다.`,
    });
};

// 친구 요청 거절 알림 함수
const sendFriendRejectNotification = async (token, senderId) => {
    await sendNotification(token, {
        title: '친구 요청 거절',
        body: `${senderId}님이 친구 요청을 거절했습니다.`,
    });
};

module.exports = {
    sendNotification,
    sendFriendRequestNotification,
    sendFriendAcceptNotification,
    sendFriendRejectNotification,
};