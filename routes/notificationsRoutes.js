const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notificationsController');
const NotificationLog = require('../models/notificationModel');
const authenticateToken = require('../auth');

const admin = require('firebase-admin')

//비밀키 경로 설정

let serAccount = require('../서버 키 이름.json') 

admin.initializeApp({
    credential: admin.credential.cert(serAccount),
})

