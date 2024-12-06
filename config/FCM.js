const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin SDK 초기화
const serviceAccount = path.join('/home/ubuntu/nodetest/firebase-adminsdk.json');

const firebaseKeys = {
    type: serviceAccount.type,
    projectId: serviceAccount.project_id,
    privateKeyId: serviceAccount.private_key_id,
    privateKey: serviceAccount.private_key,
    clientEmail: serviceAccount.client_email,
    clientId: serviceAccount.client_id,
    authUri: serviceAccount.auth_uri,
    tokenUri: serviceAccount.token_uri,
    authProviderX509CertUrl: serviceAccount.auth_provider_x509_cert_url,
    clientC509CertUrl: serviceAccount.client_x509_cert_url,
};


try {
    if (!admin.apps.length) { // 중복 초기화 방지
        admin.initializeApp({
            credential: admin.credential.cert(require(firebaseKeys)),
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
