const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin SDK 초기화
const serviceAccountPath = path.join('/home/ubuntu/nodetest/firebase-adminsdk.json');

try {
    if (!admin.apps.length) { // 중복 초기화 방지
        admin.initializeApp({
            credential: admin.credential.cert(require(serviceAccountPath)),
        });
        console.log('Firebase Admin SDK initialized successfully using JSON file.');
    } else {
        console.log('Firebase Admin SDK already initialized.');
    }
} catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error.message);
    throw new Error('Failed to initialize Firebase Admin SDK');
}

// FCM 메시지 전송 로직
const sendNotification = async (token, title, body) => {
    const message = {
        notification: { title, body },
        token,
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Notification sent successfully:', response);
        return response;
    } catch (error) {
        console.error('Error sending notification:', error);
        throw error;
    }
};

module.exports = { sendNotification };
