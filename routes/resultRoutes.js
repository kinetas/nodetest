// const express = require('express');
// const router = express.Router();
// const { getAchievementRates } = require('../controllers/resultController');
// // const requireAuth = require('../middleware/authMiddleware'); // requireAuth 미들웨어 경로 확인

// // 사용자 달성률 API 라우트
// router.get('/achievement-rates', async (req, res) => {
//     try {
//         const result = await getAchievementRates(req); // req 전달

//         if (result.success) {
//             res.status(200).json(result); // 성공 시 데이터 반환
//         } else {
//             res.status(400).json(result); // 실패 시 메시지 반환
//         }
//     } catch (error) {
//         console.error('API 요청 처리 중 오류:', error);
//         res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
//     }
// });

// module.exports = router;