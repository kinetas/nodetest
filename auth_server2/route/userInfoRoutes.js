// routes/userInfoRoutes.js
const express = require('express');
const router = express.Router();
const userInfoController = require('../controller/userInfoController');
const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 미들웨어
const multer = require('multer');
const upload = multer();

router.get('/user-id', loginRequired, userInfoController.getLoggedInUserId);
router.get('/user-nickname', loginRequired, userInfoController.getLoggedInUserNickname);
router.get('/user-all', loginRequired, userInfoController.getLoggedInUserAll);

router.post('/chaingeProfileImage', loginRequired, upload.single('image'), userInfoController.chaingeProfileImage);

module.exports = router;