const express = require('express');
const router = express.Router();
const multer = require('multer');
const cVoteController = require('../controllers/cVoteController');

const storage = multer.memoryStorage();
const upload = multer({ storage });

router.get('/', cVoteController.getVotes); // 투표 리스트 가져오기
//router.post('/create', cVoteController.createVote); // 투표 생성
router.post('/create', upload.single('c_image'), cVoteController.createVote);
router.post('/action', cVoteController.voteAction); // 투표 good/bad 업데이트
router.get('/myVotes', cVoteController.getMyVotes); 
router.delete('/delete/:c_number', cVoteController.deleteVote); // 투표 삭제 추가
router.get('/details/:c_number', cVoteController.getVoteDetails);

module.exports = router;
