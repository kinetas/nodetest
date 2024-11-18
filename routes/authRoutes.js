const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const findInfoController = require('../controllers/findInfoController');

router.post('/login', authController.login);
router.post('/register', authController.register);
router.post('/findUid', findInfoController.findUid); // 아이디 찾기 경로 추가
router.post('/changePassword', findInfoController.changePassword); // 비밀번호 변경 경로 추가
router.post('/logout', authController.logOut); // 로그아웃 경로 추가

// app.get('/check-session', (req, res) => {
//     if (!req.session.user) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }
//     res.json({ user: req.session.user });
// });

module.exports = router;
