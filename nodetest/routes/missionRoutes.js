// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions, getAssignedMissions, getCreatedMissions, getCompletedMissions, 
        getGivenCompletedMissions, getFriendAssignedMissions, getFriendCompletedMissions, getMissionsWithGrantedAuthority, 
        requestMissionApproval, createMission, deleteMission, successMission, failureMission, printRoomMission,
        requestVoteForMission, getRequestedSelfMissions, getCreatedMissionsReq  } = require('../controllers/missionController');

 const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 인증 미들웨어

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

//=======================token=========================

// ✅ 모든 API에 JWT 인증 적용
router.get('/missions', loginRequired, getUserMissions); // dashboard
router.get('/missions/assigned', loginRequired, getAssignedMissions); //printmissionlist
router.get('/missions/created', loginRequired, getCreatedMissions); //printmissionlist
router.get('/missions/created_req', loginRequired, getCreatedMissionsReq); //현재 사용하는 곳 없음(?)
router.get('/missions/completed', loginRequired, getCompletedMissions); //printmissionlist
router.get('/missions/givenCompleted', loginRequired, getGivenCompletedMissions); //printmissionlist
router.get('/missions/friendAssigned', loginRequired, getFriendAssignedMissions); //printmissionlist
router.get('/missions/friendCompleted', loginRequired, getFriendCompletedMissions); //printmissionlist
router.get('/missions/grantedAuthority', loginRequired, getMissionsWithGrantedAuthority); //printmissionlist
router.get('/missions/selfRequested', loginRequired, getRequestedSelfMissions); //printmissionlist

router.post('/missionVote', loginRequired, upload.single('c_image'), requestVoteForMission);
router.post('/missioncreate', loginRequired, createMission); // dashboard
router.delete('/missiondelete', loginRequired, deleteMission);
router.post('/successMission', loginRequired, successMission);
router.post('/failureMission', loginRequired, failureMission);
router.post('/printRoomMission', loginRequired, printRoomMission);
router.post('/missionRequest', loginRequired, requestMissionApproval);

module.exports = router;