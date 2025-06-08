// User 모델 불러오기
const User = require('../model/userModel'); // 경로를 확인하세요
const { Op } = require('sequelize'); // 추가: Sequelize의 Op 객체 가져오기
const axios = require('axios');

//================JWT===================
const { generateToken } = require('./jwt'); // jwt 토큰 생성 파일 불러오기

const { hashPassword, comparePassword } = require('../util/passwordUtils'); // 암호화 모듈 가져오기

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

     // ✅ 닉네임 중복 확인
     const existing = await User.findOne({ where: { u_nickname } });
     if (existing) {
         return res.status(409).json({ success: false, message: '이미 사용 중인 닉네임입니다.' });
     }

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

        return res.status(201).json({ success: true, message: '회원가입 성공' });
    } catch (err) {
        console.error('회원가입 실패:', err.response?.data || err.message);
        return res.status(500).json({ success: false, message: '회원가입 실패', error: err.message });
    }
};

// KeyCloak + JWT (index화면에서 로그인)
exports.keycloakDirectLogin = async (req, res) => {
    const { username, password, deviceToken } = req.body;

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

        if (deviceToken) {
            const user = await User.findOne({ where: { u_id: payload.userId } });
            if (user) {
                user.token = deviceToken;
                await user.save();
            }
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
        // await RMessage.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
        // await Mission.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
        // await Room.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });
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

// ✅ Keycloak 로그아웃 URL 반환 + JWT 제거
exports.logoutToken = async (req, res) => {
    try {
        const { idToken } = req.body;
        console.log("id_token(authController.js:368): ", idToken)
        // const redirectUri = 'http://27.113.11.48:3000/'; // 로그아웃 후 돌아갈 경로
        const redirectUri = 'http://13.125.65.151:3000/'; // 로그아웃 후 돌아갈 경로

        if (!idToken) {
            return res.status(400).json({
                success: false,
                message: 'id_token이 없습니다.'
            });
        }

        // JWT 쿠키 방식일 경우 삭제 가능
        res.clearCookie('jwt_token');

        const userId = req.currentUserId;

        // ✅ 디바이스 토큰 제거
        const user = await User.findOne({ where: { u_id: userId } });
        if (user) {
            user.token = null;
            await user.save();
            console.log(`✅ 로그아웃 시 DB의 토큰 삭제 완료 (user: ${userId})`);
        }
 

        // Keycloak 로그아웃 URL 생성
        const logoutUrl = `http://27.113.11.48:8080/realms/master/protocol/openid-connect/logout?` +
                          `id_token_hint=${encodeURIComponent(idToken)}&` +
                          `post_logout_redirect_uri=${encodeURIComponent(redirectUri)}`;

        return res.status(200).json({
            success: true,
            message: 'Keycloak 로그아웃 URL 생성 완료',
            logoutUrl
        });
    } catch (error) {
        console.error('🚫 로그아웃 처리 중 오류(authController.js:392):', error.message);
        return res.status(500).json({
            success: false,
            message: '서버 오류로 로그아웃 URL 생성에 실패했습니다.',
            error: error.message
        });
    }
};