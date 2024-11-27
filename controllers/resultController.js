// controllers/resultController.js
const MResult = require('../models/m_resultModel'); // m_resultModel.js 연결
const { Op } = require('sequelize');

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
// 일일 달성률 계산
exports.getDailyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const todayStart = new Date(now.setHours(0, 0, 0, 0));
        const todayEnd = new Date(now.setHours(23, 59, 59, 999));

        const totalMissions = await MResult.count({
            where: { u_id: userId },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: 'completed',
                m_deadline: { [Op.between]: [todayStart, todayEnd] },
            },
        });

        return totalMissions ? (completedMissions / totalMissions) * 100 : 0;
    } catch (error) {
        console.error('일일 달성률 계산 오류:', error);
        throw error;
    }
};

// 주간 달성률 계산
exports.getWeeklyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const today = new Date(now.setHours(0, 0, 0, 0));
        const weekStart = new Date(today);
        weekStart.setDate(today.getDate() - today.getDay());
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekEnd.getDate() + 6);

        const totalMissions = await MResult.count({
            where: { u_id: userId },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: 'completed',
                m_deadline: { [Op.between]: [weekStart, weekEnd] },
            },
        });

        return totalMissions ? (completedMissions / totalMissions) * 100 : 0;
    } catch (error) {
        console.error('주간 달성률 계산 오류:', error);
        throw error;
    }
};

// 월간 달성률 계산
exports.getMonthlyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
        const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0);

        const totalMissions = await MResult.count({
            where: { u_id: userId },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: 'completed',
                m_deadline: { [Op.between]: [monthStart, monthEnd] },
            },
        });

        return totalMissions ? (completedMissions / totalMissions) * 100 : 0;
    } catch (error) {
        console.error('월간 달성률 계산 오류:', error);
        throw error;
    }
};

// 연간 달성률 계산
exports.getYearlyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const yearStart = new Date(now.getFullYear(), 0, 1);
        const yearEnd = new Date(now.getFullYear(), 11, 31);

        const totalMissions = await MResult.count({
            where: { u_id: userId },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: 'completed',
                m_deadline: { [Op.between]: [yearStart, yearEnd] },
            },
        });

        return totalMissions ? (completedMissions / totalMissions) * 100 : 0;
    } catch (error) {
        console.error('연간 달성률 계산 오류:', error);
        throw error;
    }
};