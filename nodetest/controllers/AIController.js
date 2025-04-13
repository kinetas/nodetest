const axios = require('axios');
const Mission = require('../models/missionModel');
const { extractUserIdFromToken } = require('./userInfoController');


// 서버 주소
// const AI_SERVER_URL = 'http://27.113.11.48:8000';
// const INTENT_SERVER_URL = 'http://27.113.11.48:8002';


const INTENT_SERVER_URL = 'http://intent_server:8002';
const AI_SERVER_URL = 'http://rag_server:8000';

exports.askQuestion = async (req, res) => {
  const { question} = req.body;
  const user_id = extractUserIdFromToken(req);

  if (!question || !user_id) {
    return res.status(400).json({ error: '질문과 user_id가 필요합니다.' });
  }

  try {
    // 1. Intent 분류
    const intentRes = await axios.post(`${INTENT_SERVER_URL}/intent-classify`, {
      text: question,
    });

    const intent = intentRes.data.intent;
    let finalQuestion = question;

    if (intent === 'generic') {
      // 2. DB에서 해당 유저의 미션 카테고리 top3 가져오기
      const results = await Mission.findAll({
        where: { user_id },
        attributes: ['category'],
        group: ['category'],
        raw: true,
      });

      if (results.length > 0) {
        // 카테고리별 횟수 집계
        const categoryCount = {};
        results.forEach((row) => {
          const category = row.category;
          categoryCount[category] = (categoryCount[category] || 0) + 1;
        });

        // 정렬 후 상위 3개 중 랜덤 선택
        const top3 = Object.entries(categoryCount)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map((item) => item[0]);

        const chosenCategory = top3[Math.floor(Math.random() * top3.length)];
        finalQuestion = `${chosenCategory} ${question}`;
      }
    }

    // 3. AI 서버에 전달
    const aiRes = await axios.post(`${AI_SERVER_URL}/recommend`, {
      category: finalQuestion,
    });

    res.status(200).json({ result: aiRes.data });

  } catch (error) {
    console.error('❌ 에러:', error.message);
    res.status(500).json({ error: '서버 오류' });
  }
}
exports.receiveAiMessage = (req, res) => {
  const { message, category } = req.body;

  if (!message || !category) {
    return res.status(400).json({ error: "message와 category가 필요합니다." });
  }

  // 콘솔 로그로 확인
  console.log(`📩 AI 서버로부터 메시지 수신됨`);
  console.log(`- category: ${category}`);
  console.log(`- message: ${message}`);

  // 일단 응답만 간단하게
  res.status(200).json({ success: true, message: "메시지 수신 완료" });
};

exports.getLatestAiMessage = (req, res) => {
  if (!latestAiMessage) {
    return res.status(404).json({ error: '아직 메시지가 없습니다.' });
  }
  res.status(200).json(latestAiMessage);
};