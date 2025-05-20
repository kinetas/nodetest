const express = require('express');
const router = express.Router();
const c_missionController = require('../controllers/c_missionController');
const loginRequired = require('../middleware/loginRequired'); // JWT 기반 인증 미들웨어
const multer = require('multer');
// 메모리 저장소로 설정 (DB 저장용)
const storage = multer.memoryStorage();
const upload = multer({ storage });

// 커뮤니티 미션
router.post('/create', loginRequired, c_missionController.createCommunityMission);
router.post('/accept', loginRequired, c_missionController.acceptCommunityMission);
router.delete('/delete', loginRequired, c_missionController.deleteCommunityMission);
router.get('/list', loginRequired, c_missionController.getCommunityMission);
router.get('/getCommunityMissionSimple', loginRequired, c_missionController.getCommunityMissionSimple);

// 일반 커뮤니티
router.post('/createGeneralCommunity', loginRequired, upload.single('image'), c_missionController.createCommunity);
router.post('/deleteGeneralCommunity', loginRequired, c_missionController.deleteGeneralCommunity);
router.get('/printGeneralCommunityList', loginRequired, c_missionController.printGeneralCommunity);
router.get('/printGeneralCommunitySimple', loginRequired, c_missionController.printGeneralCommunitySimple);

// 추천, 인기글
router.post('/recommendCommunity', loginRequired, c_missionController.recommendCommunity);
router.get('/getpopularyityCommunityList', loginRequired, c_missionController.getPopularyityCommunity);
router.get('/getpopularyityCommunitySimple', loginRequired, c_missionController.getPopularyityCommunitySimple);

// 댓글
router.post('/getOneCommunity', loginRequired, c_missionController.getOneCommunity);    // community_comments.html
router.post('/getCommunityComments', loginRequired, c_missionController.getCommunityComments);
router.post('/writeComment', loginRequired, c_missionController.writeComment);
router.post('/deleteComment', loginRequired, c_missionController.deleteComment);
router.post('/recommendComment', loginRequired, c_missionController.recommendComment);

// 모든 커뮤니티
router.get('/getAllCommunityList', loginRequired, c_missionController.getAllCommunity);

module.exports = router;