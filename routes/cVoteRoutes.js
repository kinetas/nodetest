const express = require('express');
const router = express.Router();
const cVoteController = require('../controllers/cVoteController');

router.get('/', cVoteController.getVotes); // 투표 리스트 가져오기
router.post('/create', cVoteController.createVote); // 투표 생성
router.post('/action', cVoteController.voteAction); // 투표 good/bad 업데이트

module.exports = router;