const express = require('express');
const router = express.Router();
const axios = require('axios');
const aiController = require('../controllers/AIController');
const { sequelize } = require('../models/missionModel'); // 또는 DB 설정 경로


// // FastAPI 주소
// const RAG_SERVER_URL = 'http://rag_server:8000/recommend'; // Docker 내부 주소

// router.post('/recommend', async (req, res) => {
//     const { message } = req.body;

//     try {
//         const response = await axios.post(RAG_SERVER_URL, {
//             category: message
//         });
//         return res.json({ result: response.data.message });
//     } catch (error) {
//         console.error('RAG 서버 요청 실패:', error.message);
//         return res.status(500).json({ error: '추천 요청 실패' });
//     }
// });

router.post('/ask', aiController.askQuestion);
router.post('/receiveAiMessage', aiController.receiveAiMessage);
// router.get('/latest', aiController.getLatestAiMessage);

module.exports = router;