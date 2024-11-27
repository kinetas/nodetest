const admin = require('firebase-admin');
const path = require('path');

// Firebase 서비스 계정 키 파일을 경로 설정
const serviceAccount = require(path.join(__dirname, 'path/to/serviceAccountKey.json'));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

// 알림 전송 함수
const sendNotification = (token, payload) => {
    return admin.messaging().send({
        token: token,
        notification: {
            title: payload.title,
            body: payload.body,
        },
        data: payload.data || {},
    })
    .then(response => {
        console.log('푸시메시지 전송 성공!:', response);
    })
    .catch(error => {
        console.error('푸시메시지 전송 실패!:', error);
    });
};

module.exports = {
    sendNotification,
};