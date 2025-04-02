const axios = require('axios');

// AI 서버 주소 (내부 주소 기반 - 실제 환경에 맞게 수정)
const AI_SERVER_URL = 'http://27.113.11.48:8000';

exports.askQuestion = async (req, res) => {
  const { question } = req.body;
  if (!question) {
    return res.status(400).json({ error: '질문 텍스트가 필요합니다.' });
  }
  try {
    // AI 서버에 질문을 전송 (JSON 형식)
    const response = await axios.post(AI_SERVER_URL, { question });
    // AI 서버의 응답을 클라이언트(플러터)로 전달
    res.status(200).json({ result: response.data });
  } catch (error) {
    console.error('AI 서버 요청 실패:', error.message);
    res.status(500).json({ error: 'AI 서버와 통신 실패' });
  }
};