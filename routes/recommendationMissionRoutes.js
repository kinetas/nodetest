const express = require('express');
const router = express.Router();
const recommendationMissionController = require('../controllers/recommendationMissionController');
const missionController = require('../controllers/missionController');


// 추천 미션 카테고리별 데이터 API
router.get('/', recommendationMissionController.getRecommendationsByCategory);

// 추천 미션 생성 API
router.post('/create-mission', missionController.createMissionFromRecommendation);

module.exports = router;
