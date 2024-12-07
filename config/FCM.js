const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin SDK 초기화
const serviceAccountPath = path.join('/home/ubuntu/nodetest/firebase-adminsdk.json');
let serviceAccount;

try {
    // JSON 파일에서 객체로 변환
    serviceAccount = require(serviceAccountPath);
} catch (error) {
    console.error('Error loading service account JSON file:', error.message);
    throw new Error('Failed to load Firebase service account file');
}

try {
    if (!admin.apps.length) { // 중복 초기화 방지
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        console.log('Firebase Admin SDK initialized successfully.');
    } else {
        console.log('Firebase Admin SDK already initialized.');
    }
} catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error.message);
    throw new Error('Failed to initialize Firebase Admin SDK');
}

module.exports = admin;
