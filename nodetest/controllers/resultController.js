// controllers/resultController.js
const MResult = require('../models/m_resultModel'); // m_resultModel.js 연결
const { Op } = require('sequelize');

// m_result에 데이터 저장 함수
exports.saveResult = async (m_id, u_id, m_deadline, m_status, category, mission_result_image) => {
    try {
        await MResult.create({
            m_id,
            u_id,
            m_deadline,
            m_status,
            category,
            mission_result_image,
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

        console.log('일일 달성률 - 시작:', todayStart, '종료:', todayEnd);

        const totalMissions = await MResult.count({
            where: { 
                u_id: userId,
                m_deadline: { [Op.between]: [todayStart, todayEnd] }    //추가
             },
        });

        console.log('전체 미션 개수:', totalMissions);

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: '성공', // 필터 조건 수정
                m_deadline: { [Op.between]: [todayStart, todayEnd] },
            },
        });

        console.log('완료된 미션 개수:', completedMissions);

        const rate = totalMissions ? (completedMissions / totalMissions) * 100 : 0;

        return Math.round(rate * 10) / 10; // 소수 첫 번째 자리 반올림
    } catch (error) {
        console.error('일일 달성률 계산 오류:', error);
        throw error;
    }
};

// 주간 달성률 계산
exports.getWeeklyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const currentDay = now.getDay(); // 현재 요일 (0: 일요일, 1: 월요일, ...)
        const weekStart = new Date(now);
        weekStart.setDate(now.getDate() - currentDay + 1); // 월요일로 이동
        weekStart.setHours(0, 0, 0, 0);

        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6); // 일요일로 이동
        weekEnd.setHours(23, 59, 59, 999);

        console.log('주간 달성률 - 시작:', weekStart, '종료:', weekEnd);

        const totalMissions = await MResult.count({
            where: { 
                u_id: userId,
                m_deadline: { [Op.between]: [weekStart, weekEnd] },
            },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: '성공',
                m_deadline: { [Op.between]: [weekStart, weekEnd] },
            },
        });

        const rate = totalMissions ? (completedMissions / totalMissions) * 100 : 0;

        return Math.round(rate * 10) / 10;
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
        monthStart.setHours(0, 0, 0, 0);

        const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0); // 해당 월의 마지막 날
        monthEnd.setHours(23, 59, 59, 999);

        console.log('월간 달성률 - 시작:', monthStart, '종료:', monthEnd);

        const totalMissions = await MResult.count({
            where: { 
                u_id: userId,
                m_deadline: { [Op.between]: [monthStart, monthEnd] },
            },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: '성공',
                m_deadline: { [Op.between]: [monthStart, monthEnd] },
            },
        });

        const rate = totalMissions ? (completedMissions / totalMissions) * 100 : 0;

        return Math.round(rate * 10) / 10;
    } catch (error) {
        console.error('월간 달성률 계산 오류:', error);
        throw error;
    }
};

// 연간 달성률 계산
exports.getYearlyAchievementRate = async (userId) => {
    try {
        const now = new Date();
        const yearStart = new Date(now.getFullYear(), 0, 1); // 해당 연도의 1월 1일
        yearStart.setHours(0, 0, 0, 0);

        const yearEnd = new Date(now.getFullYear(), 11, 31); // 해당 연도의 12월 31일
        yearEnd.setHours(23, 59, 59, 999);

        console.log('연간 달성률 - 시작:', yearStart, '종료:', yearEnd);

        const totalMissions = await MResult.count({
            where: { 
                u_id: userId,
                m_deadline: { [Op.between]: [yearStart, yearEnd] },
            },
        });

        const completedMissions = await MResult.count({
            where: {
                u_id: userId,
                m_status: '성공',
                m_deadline: { [Op.between]: [yearStart, yearEnd] },
            },
        });

        const rate = totalMissions ? (completedMissions / totalMissions) * 100 : 0;

        return Math.round(rate * 10) / 10;
    } catch (error) {
        console.error('연간 달성률 계산 오류:', error);
        throw error;
    }
};

// ✅ 성공한 미션 수 조회
exports.getSuccessMissionNumber = async (userId) => {
    try {
        const successCount = await MResult.count({
            where: {
                u_id: userId,
                m_status: '성공',
            },
        });
        return successCount;
    } catch (error) {
        console.error('성공한 미션 수 조회 오류:', error);
        throw error;
    }
};

// ✅ 실패한 미션 수 조회
exports.getFailMissionNumber = async (userId) => {
    try {
        const failCount = await MResult.count({
            where: {
                u_id: userId,
                m_status: '실패',
            },
        });
        return failCount;
    } catch (error) {
        console.error('실패한 미션 수 조회 오류:', error);
        throw error;
    }
};