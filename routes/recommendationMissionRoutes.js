const express = require('express');
const router = express.Router();
const recommendationMissionController = require('../controllers/recommendationMissionController');

// 추천 미션 페이지 라우트
router.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/recommendationMission.html'));
});

// 추천 미션 카테고리별 데이터 API
router.get('/api/recommendations', recommendationMissionController.getRecommendationsByCategory);

module.exports = router;
