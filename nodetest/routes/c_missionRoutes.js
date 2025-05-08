const express = require('express');
const router = express.Router();
const c_missionController = require('../controllers/c_missionController');
const loginRequired = require('../middleware/loginRequired'); // JWT 기반 인증 미들웨어
const multer = require('multer');
// 메모리 저장소로 설정 (DB 저장용)
const storage = multer.memoryStorage();
const upload = multer({ storage });

router.post('/create', loginRequired, c_missionController.createCommunityMission);
router.post('/accept', loginRequired, c_missionController.acceptCommunityMission);
router.delete('/delete', loginRequired, c_missionController.deleteCommunityMission);

router.get('/list', loginRequired, c_missionController.getCommunityMission);

router.post('/createGeneralCommunity', loginRequired, upload.single('image'), c_missionController.createCommunity);
router.get('/printGeneralCommunityList', loginRequired, c_missionController.printGeneralCommunity);
router.post('/recommendCommunity', loginRequired, c_missionController.recommendCommunity);

module.exports = router;