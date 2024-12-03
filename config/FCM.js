const dotenv = require('dotenv');
const admin = require('firebase-admin');

dotenv.config();

// Firebase Admin SDK 초기화
const serviceAccount = process.env.SECRET_KEY;

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

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