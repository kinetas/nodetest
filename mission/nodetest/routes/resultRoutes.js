const express = require('express');
const router = express.Router();
const resultController = require('../controllers/resultController');
// const requireAuth = require('../middleware/authMiddleware'); // 인증 미들웨어
const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 인증 미들웨어로 변경

// // 일일 달성률
// router.get('/daily', requireAuth, async (req, res) => {
//     try {
//         const userId = req.session.user.id;
//         const dailyRate = await resultController.getDailyAchievementRate(userId);
//         res.json({ dailyRate });
//     } catch (error) {
//         res.status(500).json({ error: '일일 달성률 계산 실패' });
//     }
// });

// // 주간 달성률
// router.get('/weekly', requireAuth, async (req, res) => {
//     try {
//         const userId = req.session.user.id;
//         const weeklyRate = await resultController.getWeeklyAchievementRate(userId);
//         res.json({ weeklyRate });
//     } catch (error) {
//         res.status(500).json({ error: '주간 달성률 계산 실패' });
//     }
// });

// // 월간 달성률
// router.get('/monthly', requireAuth, async (req, res) => {
//     try {
//         const userId = req.session.user.id;
//         const monthlyRate = await resultController.getMonthlyAchievementRate(userId);
//         res.json({ monthlyRate });
//     } catch (error) {
//         res.status(500).json({ error: '월간 달성률 계산 실패' });
//     }
// });

// // 연간 달성률
// router.get('/yearly', requireAuth, async (req, res) => {
//     try {
//         const userId = req.session.user.id;
//         const yearlyRate = await resultController.getYearlyAchievementRate(userId);
//         res.json({ yearlyRate });
//     } catch (error) {
//         res.status(500).json({ error: '연간 달성률 계산 실패' });
//     }
// });


//===============================token=================================

// ✅ JWT 기반 사용자 인증 적용
router.get('/daily', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT로부터 추출
        const dailyRate = await resultController.getDailyAchievementRate(userId);
        res.json({ dailyRate });
    } catch (error) {
        res.status(500).json({ error: '일일 달성률 계산 실패' });
    }
});

router.get('/weekly', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT 기반
        const weeklyRate = await resultController.getWeeklyAchievementRate(userId);
        res.json({ weeklyRate });
    } catch (error) {
        res.status(500).json({ error: '주간 달성률 계산 실패' });
    }
});

router.get('/monthly', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT 기반
        const monthlyRate = await resultController.getMonthlyAchievementRate(userId);
        res.json({ monthlyRate });
    } catch (error) {
        res.status(500).json({ error: '월간 달성률 계산 실패' });
    }
});

router.get('/yearly', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId; // ✅ JWT 기반
        const yearlyRate = await resultController.getYearlyAchievementRate(userId);
        res.json({ yearlyRate });
    } catch (error) {
        res.status(500).json({ error: '연간 달성률 계산 실패' });
    }
});

// ✅ 성공한 미션 수 조회 API
router.get('/success-count', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId;
        const successCount = await resultController.getSuccessMissionNumber(userId);
        res.json({ successCount });
    } catch (error) {
        res.status(500).json({ error: '성공한 미션 수 조회 실패' });
    }
});

// ✅ 실패한 미션 수 조회 API
router.get('/fail-count', loginRequired, async (req, res) => {
    try {
        const userId = req.currentUserId;
        const failCount = await resultController.getFailMissionNumber(userId);
        res.json({ failCount });
    } catch (error) {
        res.status(500).json({ error: '실패한 미션 수 조회 실패' });
    }
});

module.exports = router;