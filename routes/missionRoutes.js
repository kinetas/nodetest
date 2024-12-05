// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions, getAssignedMissions, getCreatedMissions, getCompletedMissions, 
        getGivenCompletedMissions, getFriendAssignedMissions, getFriendCompletedMissions, getMissionsWithGrantedAuthority, 
        requestMissionApproval, createMission, deleteMission, successMission, failureMission, printRoomMission  } = require('../controllers/missionController');
const requireAuth = require('../middleware/authMiddleware'); // requireAuth 미들웨어 경로 확인

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

// 미션 리스트 반환 라우트
router.get('/missions', requireAuth, getUserMissions);

// 자신이 수행해야 할 미션
router.get('/missions/assigned', requireAuth, getAssignedMissions);

// 자신이 부여한 미션
router.get('/missions/created', requireAuth, getCreatedMissions);

// 자신이 완료한 미션 
router.get('/missions/completed', requireAuth, getCompletedMissions);

// 자신이 부여한 미션 중 상대가 완료한 미션 
router.get('/missions/givenCompleted', requireAuth, getGivenCompletedMissions);

// 친구가 수행해야 하는 미션
router.get('/missions/friendAssigned', requireAuth, getFriendAssignedMissions);

// 친구가 완료한 미션
router.get('/missions/friendCompleted', requireAuth, getFriendCompletedMissions);

// 인증 권한을 부여한 미션 조회
router.get('/missions/grantedAuthority', requireAuth, getMissionsWithGrantedAuthority);

router.post('/missionVote', requireAuth, upload.single('c_image'), requestVoteForMission);


// 미션 생성 요청 처리
router.post('/missioncreate', requireAuth, createMission);

// 미션 삭제 요청 처리
router.delete('/missiondelete', requireAuth, deleteMission);

// 미션 성공 및 실패 요청 처리 라우트
router.post('/successMission', requireAuth, successMission);
router.post('/failureMission', requireAuth, failureMission);

// 방 미션 출력 라우트
router.post('/printRoomMission', requireAuth, printRoomMission);

// 인증 요청 라우트
router.post('/missionRequest', requireAuth, requestMissionApproval); 

module.exports = router;