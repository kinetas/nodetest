const express = require('express');
const router = express.Router();
const { getAchievementRates } = require('../controllers/resultController'); // resultController 가져오기

// 사용자 달성률 API 라우트
router.get('/achievement-rates', async (req, res) => {
    try {
        const { u_id } = req.query; // 클라이언트에서 u_id 전달받기
        if (!u_id) {
            return res.status(400).json({ success: false, message: '사용자 ID가 필요합니다.' });
        }

        const result = await getAchievementRates(u_id);

        if (result.success) {
            res.status(200).json(result); // 성공 시 달성률 데이터 반환
        } else {
            res.status(500).json(result); // 오류 발생 시 오류 메시지 반환
        }
    } catch (error) {
        console.error('API 요청 처리 중 오류:', error);
        res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
});

module.exports = router;