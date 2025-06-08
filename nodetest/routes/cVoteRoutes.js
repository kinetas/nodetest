const express = require('express');
const router = express.Router();
// const multer = require('multer');
const cVoteController = require('../controllers/cVoteController');
const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 인증 미들웨어

// const storage = multer.memoryStorage();
// const upload = multer({ storage });

router.get('/', loginRequired, cVoteController.getVotes); // 투표 리스트 가져오기
// router.post('/create', loginRequired, upload.single('c_image'), cVoteController.createVote);
router.post('/create', loginRequired, cVoteController.createVote);
router.post('/action', loginRequired, cVoteController.voteAction); // 투표 good/bad 업데이트
router.get('/myVotes', loginRequired, cVoteController.getMyVotes); 
router.delete('/delete/:c_number', loginRequired, cVoteController.deleteVote); // 투표 삭제 추가
router.get('/details', loginRequired, cVoteController.getVoteDetails);
module.exports = router;
