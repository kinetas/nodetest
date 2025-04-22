// routes/missionRoutes.js
const express = require('express');
const router = express.Router();
const { getUserMissions, getAssignedMissions, getCreatedMissions, getCompletedMissions, 
        getGivenCompletedMissions, getFriendAssignedMissions, getFriendCompletedMissions, getMissionsWithGrantedAuthority, 
        requestMissionApproval, createMission, deleteMission, successMission, failureMission, printRoomMission,
        requestVoteForMission, getRequestedSelfMissions, getCreatedMissionsReq  } = require('../controllers/missionController');
//  const requireAuth = require('../middleware/authMiddleware'); // 세션 인증 미들웨어
 const loginRequired = require('../middleware/loginRequired'); // ✅ JWT 인증 미들웨어

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

const { keycloak } = require('../keycloak'); // ✅ Keycloak protect 추가

// // 미션 리스트 반환 라우트
// router.get('/missions', requireAuth, getUserMissions);

// // 자신이 수행해야 할 미션
// router.get('/missions/assigned', requireAuth, getAssignedMissions);

// // 자신이 부여한 미션
// router.get('/missions/created', requireAuth, getCreatedMissions);

// // 자신이 부여한 미션 (요청)
// router.get('/missions/created_req', requireAuth, getCreatedMissionsReq);

// // 자신이 완료한 미션 
// router.get('/missions/completed', requireAuth, getCompletedMissions);

// // 자신이 부여한 미션 중 상대가 완료한 미션 
// router.get('/missions/givenCompleted', requireAuth, getGivenCompletedMissions);

// // 친구가 수행해야 하는 미션
// router.get('/missions/friendAssigned', requireAuth, getFriendAssignedMissions);

// // 친구가 완료한 미션
// router.get('/missions/friendCompleted', requireAuth, getFriendCompletedMissions);

// // 인증 권한을 부여한 미션 조회
// router.get('/missions/grantedAuthority', requireAuth, getMissionsWithGrantedAuthority);

// // ====== 투표 요청 라우트 (수정된 부분) ======
// router.post('/missionVote', requireAuth, upload.single('c_image'), requestVoteForMission);
// // 사진 업로드 없이 JSON 데이터만 처리
// // router.post('/missionVote', requireAuth, requestVoteForMission);

// router.get('/missions/selfRequested', requireAuth, getRequestedSelfMissions);


// // 미션 생성 요청 처리
// router.post('/missioncreate', requireAuth, createMission);

// // 미션 삭제 요청 처리
// router.delete('/missiondelete', requireAuth, deleteMission);

// // 미션 성공 및 실패 요청 처리 라우트
// router.post('/successMission', requireAuth, successMission);
// router.post('/failureMission', requireAuth, failureMission);

// // 방 미션 출력 라우트
// router.post('/printRoomMission', requireAuth, printRoomMission);

// // 인증 요청 라우트
// router.post('/missionRequest', requireAuth, requestMissionApproval); 

//=======================token=========================

// ✅ 모든 API에 JWT 인증 적용
router.get('/missions', loginRequired, getUserMissions);
router.get('/missions/assigned', loginRequired, getAssignedMissions);
router.get('/missions/created', loginRequired, getCreatedMissions);
router.get('/missions/created_req', loginRequired, getCreatedMissionsReq);
router.get('/missions/completed', loginRequired, getCompletedMissions);
router.get('/missions/givenCompleted', loginRequired, getGivenCompletedMissions);
router.get('/missions/friendAssigned', loginRequired, getFriendAssignedMissions);
router.get('/missions/friendCompleted', loginRequired, getFriendCompletedMissions);
router.get('/missions/grantedAuthority', loginRequired, getMissionsWithGrantedAuthority);
router.get('/missions/selfRequested', loginRequired, getRequestedSelfMissions);

router.post('/missionVote', loginRequired, upload.single('c_image'), requestVoteForMission);
router.post('/missioncreate', loginRequired, createMission);
router.delete('/missiondelete', loginRequired, deleteMission);
router.post('/successMission', loginRequired, successMission);
router.post('/failureMission', loginRequired, failureMission);
router.post('/printRoomMission', loginRequired, printRoomMission);
router.post('/missionRequest', loginRequired, requestMissionApproval);

//===============================KeyCloak==============================

// // ✅ 모든 라우트에 keycloak.protect() 적용
// router.get('/missions', keycloak.protect(), getUserMissions);
// router.get('/missions/assigned', keycloak.protect(), getAssignedMissions);
// router.get('/missions/created', keycloak.protect(), getCreatedMissions);
// router.get('/missions/created_req', keycloak.protect(), getCreatedMissionsReq);
// router.get('/missions/completed', keycloak.protect(), getCompletedMissions);
// router.get('/missions/givenCompleted', keycloak.protect(), getGivenCompletedMissions);
// router.get('/missions/friendAssigned', keycloak.protect(), getFriendAssignedMissions);
// router.get('/missions/friendCompleted', keycloak.protect(), getFriendCompletedMissions);
// router.get('/missions/grantedAuthority', keycloak.protect(), getMissionsWithGrantedAuthority);
// router.get('/missions/selfRequested', keycloak.protect(), getRequestedSelfMissions);

// router.post('/missionVote', keycloak.protect(), upload.single('c_image'), requestVoteForMission);
// router.post('/missioncreate', keycloak.protect(), createMission);
// router.delete('/missiondelete', keycloak.protect(), deleteMission);
// router.post('/successMission', keycloak.protect(), successMission);
// router.post('/failureMission', keycloak.protect(), failureMission);
// router.post('/printRoomMission', keycloak.protect(), printRoomMission);
// router.post('/missionRequest', keycloak.protect(), requestMissionApproval);

module.exports = router;