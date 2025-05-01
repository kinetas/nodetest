// User 모델 불러오기
const User = require('../models/userModel'); // 경로를 확인하세요
const Mission = require('../models/missionModel');
const Room = require('../models/roomModel');
const RMessage = require('../models/messageModel'); // r_message 모델 가져오기
const NotificationLog = require('../models/notificationModel'); // r_message 모델 가져오기
const { Op } = require('sequelize'); // 추가: Sequelize의 Op 객체 가져오기
const axios = require('axios');

//================JWT===================
const jwt = require('jsonwebtoken'); // jwt 토큰 사용을 위해 모듈 불러오기
const { generateToken } = require('./jwt'); // jwt 토큰 생성 파일 불러오기
const { addLaplaceNoise } = require('../utils/dpUtils');
//================JWT===================

const { hashPassword, comparePassword } = require('../utils/passwordUtils'); // 암호화 모듈 가져오기
const roomController = require('./roomController'); // roomController 가져오기
const { v4: uuidv4 } = require('uuid'); // 필요시 ID 생성 유틸

const {
    KEYCLOAK_ADMIN_USER,
    KEYCLOAK_ADMIN_PASS,
    KEYCLOAK_BASE_URL,
    KEYCLOAK_REALM,
    KEYCLOAK_CLIENT_ID,
    KEYCLOAK_ADMIN_SECRET,
  } = process.env;

// register 화면에서 회원가입
exports.registerKeycloakDirect = async (req, res) => {
    const { u_id, u_password, u_mail, u_nickname, u_name, u_birth } = req.body;

    try {
        // 1. 관리자 토큰 발급
        const tokenRes = await axios.post(
            'http://27.113.11.48:8080/realms/master/protocol/openid-connect/token',
            new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: KEYCLOAK_CLIENT_ID,
                client_secret: KEYCLOAK_ADMIN_SECRET
            }),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );
        const adminToken = tokenRes.data.access_token;
        console.log("admintoken: ", adminToken);

        // 2. Keycloak 사용자 생성
        await axios.post(
            'http://27.113.11.48:8080/admin/realms/master/users',
            {
                username: u_id,
                enabled: true,
                email: u_mail,
                attributes: {
                    name: [u_name],
                    nickname: [u_nickname],
                    birth: [u_birth],
                },
                credentials: [
                    {
                        type: 'password',
                        value: u_password,
                        temporary: false
                    }
                ]
            },
            { headers: { Authorization: `Bearer ${adminToken}` } }
        );

        // 3. 우리 DB에 사용자 정보 저장
        const hashed = await hashPassword(u_password);
        await User.create({
            u_id,
            u_password: hashed,
            u_mail,
            u_nickname,
            u_name,
            u_birth
        });

        // // 4. room 생성
        // const roomResult = await roomController.initAddRoom({ body: { u1_id: u_id } });
        // if (!roomResult.success) {
        //     console.error('방 생성 실패:', roomResult.error);
        //     return res.status(500).json({ message: '회원가입은 완료되었으나 방 생성에 실패했습니다.' });
        // }

        return res.status(201).json({ success: true, message: '회원가입 성공' });
    } catch (err) {
        console.error('회원가입 실패:', err.response?.data || err.message);
        return res.status(500).json({ success: false, message: '회원가입 실패', error: err.message });
    }
};

// // Keycloak 직접 로그인 처리 (index 화면에서 로그인)
// exports.keycloakDirectLogin = async (req, res) => {
//     const { username, password } = req.body;

//     try {
//         const tokenRes = await axios.post(
//             'http://27.113.11.48:8080/realms/master/protocol/openid-connect/token',
//             new URLSearchParams({
//                 grant_type: 'password',
//                 client_id: 'nodetest',
//                 client_secret: 'HxCBsoCzp0rldTc3ZiuA7QLtXm1jjFnH',
//                 username,
//                 password,
//                 scope: 'openid',
//             }),
//             {
//                 headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
//             }
//         );

//         const { access_token, id_token } = tokenRes.data;

//         return res.status(200).json({
//             success: true,
//             accessToken: access_token,
//             idToken: id_token,
//         });
//     } catch (error) {
//         console.error('[Keycloak 로그인 실패]', error.response?.data || error.message);
//         return res.status(401).json({
//             success: false,
//             message: 'Keycloak 로그인 실패',
//             error: error.response?.data || error.message
//         });
//     }
// };


// KeyCloak + JWT (index화면에서 로그인)
exports.keycloakDirectLogin = async (req, res) => {
    const { username, password } = req.body;

    try {
        //Keycloak 로그인으로 access_token 획득
        const tokenRes = await axios.post(
            'http://27.113.11.48:8080/realms/master/protocol/openid-connect/token',
            new URLSearchParams({
                grant_type: 'password',
                client_id: 'nodetest',
                client_secret: 'HxCBsoCzp0rldTc3ZiuA7QLtXm1jjFnH',
                username,
                password,
                scope: 'openid',
            }),
            {
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }
        );

        const { access_token, id_token } = tokenRes.data;

        //Keycloak에서 사용자 정보 조회
        const userInfoRes = await axios.get(
            'http://27.113.11.48:8080/realms/master/protocol/openid-connect/userinfo',
            {
                headers: { Authorization: `Bearer ${access_token}` }
            }
        );

        const userInfo = userInfoRes.data;
        const payload = {
            userId: userInfo.preferred_username || userInfo.sub,
            email: userInfo.email || null,
            nickname: userInfo.nickname || null,
            birth: userInfo.birth || null,
            name: userInfo.name || null
        };

        if (!payload.userId) {
            return res.status(400).json({ success: false, message: '유효한 사용자 ID를 얻지 못했습니다.' });
        }

        //JWT 발급
        const jwtToken = generateToken(payload);

        return res.status(200).json({
            success: true,
            accessToken: access_token,
            idToken: id_token,
            jwtToken,
            message: 'Keycloak + JWT 로그인 성공'
        });
    } catch (err) {
        console.error('[통합 로그인 실패]', err.response?.data || err.message);
        return res.status(401).json({
            success: false,
            message: 'Keycloak 로그인 또는 JWT 발급 실패',
            error: err.message
        });
    }
};

// Keycloak 로그인 리디렉션 URL 제공 API (KeyCloak 화면에서 로그인)
exports.getKeycloakLoginUrl = async (req, res) => {
    try {
        const baseUrl = 'http://27.113.11.48:8080'; // Keycloak 서버 주소
        const clientId = 'nodetest';
        // const redirectUri = 'http://27.113.11.48:3000/dashboard';
        const redirectUri = 'myapp://login-callback';
        const responseType = 'id_token token'; // Implicit flow
        const scope = 'openid';
        const nonce = 'nonce123';

        const loginUrl = `${baseUrl}/realms/master/protocol/openid-connect/auth?` +
            `client_id=${clientId}` +
            `&response_type=${encodeURIComponent(responseType)}` +
            `&scope=${scope}` +
            `&nonce=${nonce}` +
            `&redirect_uri=${encodeURIComponent(redirectUri)}`;

        res.json({ success: true, loginUrl });
    } catch (err) {
        console.error('Keycloak 로그인 URL 생성 오류:', err);
        res.status(500).json({ success: false, message: '로그인 URL 생성 실패' });
    }
};

// 계정 탈퇴
exports.deleteAccountFromKeycloak = async (req, res) => {
    const userId = req.currentUserId;

    if (!userId) {
        return res.status(401).json({ success: false, message: 'JWT 토큰이 필요합니다.' });
    }

    try {
        // 1. Keycloak 관리자 토큰 발급
        const tokenRes = await axios.post(
            `${KEYCLOAK_BASE_URL}/realms/master/protocol/openid-connect/token`,
            new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: 'nodetest',
                client_secret: KEYCLOAK_ADMIN_SECRET
            }),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );

        const adminToken = tokenRes.data.access_token;

        // 2. Keycloak 사용자 UUID 검색
        const userSearchRes = await axios.get(
            `${KEYCLOAK_BASE_URL}/admin/realms/${KEYCLOAK_REALM}/users`,
            {
                headers: { Authorization: `Bearer ${adminToken}` },
                params: { username: userId }
            }
        );

        if (!userSearchRes.data.length) {
            return res.status(404).json({ success: false, message: 'Keycloak 계정을 찾을 수 없습니다.' });
        }

        const keycloakUserId = userSearchRes.data[0].id;

        // 3. Keycloak 계정 삭제
        await axios.delete(
            `${KEYCLOAK_BASE_URL}/admin/realms/${KEYCLOAK_REALM}/users/${keycloakUserId}`,
            { headers: { Authorization: `Bearer ${adminToken}` } }
        );

        // 4. 우리 DB의 메시지, 미션, 방, 유저 삭제
        await RMessage.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
        await Mission.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
        await Room.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
        await User.destroy({ where: { u_id: userId } });

        return res.json({
            success: true,
            message: `${userId} 계정이 Keycloak 및 로컬 DB에서 모두 삭제되었습니다.`
        });
    } catch (err) {
        console.error('계정 삭제 오류:', err.response?.data || err.message);
        return res.status(500).json({
            success: false,
            message: '계정 삭제 중 오류가 발생했습니다.',
            error: err.response?.data || err.message
        });
    }
};


// ✅ Keycloak 토큰 기반 JWT 발급 API
exports.issueJwtFromKeycloak = async (req, res) => {
    try {
        const accessToken = req.body.accessToken;
        if (!accessToken) {
            return res.status(400).json({ success: false, message: 'accessToken이 없습니다.' });
        }

        const userInfoRes = await axios.get(
            'http://27.113.11.48:8080/realms/master/protocol/openid-connect/userinfo',
            {
                headers: { Authorization: `Bearer ${accessToken}` }
            }
        );

        const userInfo = userInfoRes.data;
        
        const payload = { 
            userId: userInfo.preferred_username || userInfo.sub,
            email: userInfo.email || null,
            nickname: userInfo.nickname || null,
            birth: userInfo.birth || null,
            name: userInfo.name || null
        };

        // 필수 필드 검사
        if (!payload.userId) {
            return res.status(400).json({ success: false, message: '유효한 사용자 ID를 얻지 못했습니다.' });
        }

        const token = generateToken(payload);

        return res.status(200).json({
            success: true,
            message: 'JWT 토큰이 발급되었습니다.',
            token,
        });
    } catch (err) {
        console.error('JWT 발급 오류:', err);
        return res.status(500).json({ success: false, message: '서버 오류로 JWT 발급에 실패했습니다.' });
    }
};

// 계정 탈퇴 함수
exports.deleteAccount = async (req, res) => { // 추가
    const userId = req.session.user?.id;

    if (!userId) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
    }

    try {

        // 1. r_message 데이터 삭제 (u1_id 또는 u2_id가 해당 사용자와 일치)
        await RMessage.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });

        // 2. mission 데이터 삭제
        await Mission.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });

        // 3. room 데이터 삭제
        await Room.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });

        // 4. user 데이터 삭제
        const deleted = await User.destroy({ where: { u_id: userId } });

        if (deleted) {
            req.session.destroy(); // 세션 제거
            console.log(JSON.stringify({ success: true, message: '계정이 성공적으로 삭제되었습니다.' }));
            return res.status(200).json({ success: true, message: '계정이 성공적으로 삭제되었습니다.' });
        } else {
            return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error('계정 삭제 오류:', error);
        return res.status(500).json({ success: false, message: `서버 오류(${error})가 발생했습니다. controller` });
    }
};

// ✅ JWT 기반 로그아웃 로직 (간소화 버전)
exports.logoutToken = async (req, res) => {
    res.clearCookie('jwt_token'); // 만약 쿠키 기반이라면 의미 있음
    res.json({ message: '로그아웃 되었습니다.' });
};