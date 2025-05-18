// routes/userInfoRoutes.js
const express = require('express');
const router = express.Router();
const userInfoController = require('../controllers/userInfoController');
const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 미들웨어

router.get('/user-id', loginRequired, userInfoController.getLoggedInUserId);
router.get('/user-nickname', loginRequired, userInfoController.getLoggedInUserNickname);
router.get('/user-all', loginRequired, userInfoController.getLoggedInUserAll);

router.post('/chaingeProfileImage', loginRequired, upload.single('image'), userInfoController.chaingeProfileImage);

module.exports = router;