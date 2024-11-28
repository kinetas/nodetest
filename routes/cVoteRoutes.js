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
//router.get('/details/:c_number', cVoteController.getVoteDetails);
router.get('/details/:c_number', async (req, res) => {
    const { c_number } = req.params;

    if (!c_number || c_number === 'null') {
        return res.status(400).json({ success: false, message: '유효하지 않은 c_number 값입니다.' });
    }

    try {
        const voteDetails = await cVoteController.getVoteDetails(c_number);
        if (!voteDetails) {
            return res.status(404).json({ success: false, message: '투표를 찾을 수 없습니다.' });
        }
        res.json({ success: true, vote: voteDetails });
    } catch (error) {
        console.error("Error fetching vote details:", error);
        res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
});
module.exports = router;
