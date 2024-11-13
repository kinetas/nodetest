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