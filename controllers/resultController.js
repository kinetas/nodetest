// controllers/resultController.js
const Result = require('../models/m_resultModel'); // m_result 모델 가져오기

// m_result에 데이터 저장 함수
exports.saveResult = async (m_id, u_id, m_deadline, m_status) => {
    try {
        await Result.create({
            m_id,
            u_id,
            m_deadline,
            m_status
        });
        return { success: true, message: 'm_result에 데이터가 성공적으로 저장되었습니다.' };
    } catch (error) {
        console.error('m_result 저장 오류:', error);
        return { success: false, message: 'm_result 저장 중 오류가 발생했습니다.' };
    }
};

// 일일/주간/월간/연간 달성률
// 현재 시간 기준 달성률 계산
exports.getAchievementRates = async (u_id) => {
    try {
        const now = new Date();

        // 하루의 시작과 끝 계산
        const startOfDay = new Date(now.setHours(0, 0, 0, 0));
        const endOfDay = new Date(now.setHours(23, 59, 59, 999));

        // 주의 시작과 끝 계산 (일요일 기준)
        const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
        startOfWeek.setHours(0, 0, 0, 0);
        const endOfWeek = new Date(startOfWeek);
        endOfWeek.setDate(endOfWeek.getDate() + 6);
        endOfWeek.setHours(23, 59, 59, 999);

        // 월의 시작과 끝 계산
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        endOfMonth.setHours(23, 59, 59, 999);

        // 연도의 시작과 끝 계산
        const startOfYear = new Date(now.getFullYear(), 0, 1);
        const endOfYear = new Date(now.getFullYear(), 11, 31, 23, 59, 59, 999);

        const ranges = [
            { name: 'daily', start: startOfDay, end: endOfDay },
            { name: 'weekly', start: startOfWeek, end: endOfWeek },
            { name: 'monthly', start: startOfMonth, end: endOfMonth },
            { name: 'yearly', start: startOfYear, end: endOfYear },
        ];

        const results = {};

        for (const range of ranges) {
            const totalMissions = await Result.count({
                where: {
                    u_id,
                    m_deadline: {
                        [Op.between]: [range.start, range.end],
                    },
                },
            });

            const successfulMissions = await Result.count({
                where: {
                    u_id,
                    m_status: 'success', // 성공 상태는 'success'로 가정
                    m_deadline: {
                        [Op.between]: [range.start, range.end],
                    },
                },
            });

            const achievementRate = totalMissions > 0
                ? Math.round((successfulMissions / totalMissions) * 100)
                : 0;

            results[range.name] = achievementRate;
        }

        return { success: true, data: results };
    } catch (error) {
        console.error('달성률 계산 오류:', error);
        return { success: false, message: '달성률 계산 중 오류가 발생했습니다.' };
    }
};