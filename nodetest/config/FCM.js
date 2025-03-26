const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin SDK 초기화
const serviceAccountPath = path.join(__dirname, '..', process.env.FIREBASE_CREDENTIAL);
let serviceAccount;

try {
    // JSON 파일에서 객체로 변환
    console.log('Attempting to load Service Account from:', serviceAccountPath); // 경로 확인
    serviceAccount = require(serviceAccountPath);
    console.log('Service Account Loaded:', serviceAccount ? 'Success' : 'Failed'); // 로드 성공 여부
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
