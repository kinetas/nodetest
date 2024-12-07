const MRecommand = require('../models/m_recommandModel'); // m_recommandModel 불러오기

// 추천 미션 카테고리별 가져오기
exports.getRecommendationsByCategory = async (req, res) => {
    try {
        const recommendations = await MRecommand.findAll();
        
        // 카테고리별 그룹화
        const groupedRecommendations = recommendations.reduce((acc, mission) => {
            if (!acc[mission.category]) {
                acc[mission.category] = [];
            }
            acc[mission.category].push(mission);
            return acc;
        }, {});

        res.json(groupedRecommendations);
    } catch (error) {
        console.error('추천 미션 데이터를 가져오는 중 오류 발생:', error);
        res.status(500).json({ message: '추천 미션 데이터를 가져오는 중 오류가 발생했습니다.' });
    }
};