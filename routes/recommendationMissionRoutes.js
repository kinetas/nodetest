const express = require('express');
const router = express.Router();
const recommendationMissionController = require('../controllers/recommendationMissionController');



// 추천 미션 카테고리별 데이터 API
router.get('/', recommendationMissionController.getRecommendationsByCategory);

module.exports = router;
