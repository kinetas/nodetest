// const express = require('express');
// const router = express.Router();
// const notificationsController = require('../controllers/notificationsController');
// const NotificationLog = require('../models/notificationModel');
// const authenticateToken = require('../auth');

// const admin = require('firebase-admin')

// //비밀키 경로 설정

// let serAccount = require('../서버 키 이름.json') 

// admin.initializeApp({
//     credential: admin.credential.cert(serAccount),
// })

//=================================token========================================

const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 미들웨어
const admin = require('firebase-admin');

// ✅ 서버 키 경로
const serviceAccount = require('../서버 키 이름.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// ✅ JWT 인증을 적용한 라우트
router.post('/send', loginRequired, notificationController.sendNotificationController);

module.exports = router;