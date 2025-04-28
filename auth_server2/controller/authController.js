// User 모델 불러오기
const User = require('../model/userModel'); // 경로를 확인하세요
const axios = require('axios');
const { generateToken } = require('./jwt'); // jwt 토큰 생성 파일 불러오기
const roomController = require('./roomController'); // roomController 가져오기

// Keycloak 직접 로그인 처리
exports.keycloakDirectLogin = async (req, res) => {
    const { username, password } = req.body;

    try {
        const tokenRes = await axios.post(
            'http://27.113.11.48:8080/realms/master/protocol/openid-connect/token',
            new URLSearchParams({
                grant_type: 'password',
                client_id: 'nodetest',
                client_secret: 'ptR4hZ66Q6dvBCWzdiySdk57L7Ow2OzE',
                username,
                password,
            }),
            {
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }
        );

        const { access_token, id_token } = tokenRes.data;

        return res.status(200).json({
            success: true,
            accessToken: access_token,
        });
    } catch (error) {
        console.error('[Keycloak 로그인 실패]', error.response?.data || error.message);
        return res.status(401).json({
            success: false,
            message: 'Keycloak 로그인 실패',
            error: error.response?.data || error.message
        });
    }
};

// Keycloak 로그인 리디렉션 URL 제공 API
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

// ✅ Keycloak 로그인 후 사용자 정보 기반 DB 자동 저장
exports.getOrCreateUserFromKeycloak = async (req, res) => {
    try {
      const keycloakUser = req.kauth.grant.access_token.content;
  
      const u_id = keycloakUser.preferred_username;                   // 사용자명
      const u_mail = keycloakUser.email || null;                      // 이메일
      const u_nickname = keycloakUser.nickname || 'no_nickname';      // 닉네임 (커스텀 필드)
      const u_birth = keycloakUser.birth || null;                     // 생년월일 (커스텀 필드)
      const u_name = keycloakUser.name || 'unknown';                  // 전체 이름
      const u_password = 'keycloak'; // 더미 비번 (사용되지 않음)
  
      // 🔎 이미 존재하는 사용자 찾기
      const [user, created] = await User.findOrCreate({
        where: { u_id },
        defaults: {
          u_password,
          u_nickname,
          u_name,
          u_birth,
          u_mail
        }
      });
  
      if (created) {
        console.log(`Keycloak 사용자가 DB에 등록됨: ${u_id}`);

        // 방 생성 (응답 처리 없이 결과만 확인)
        const roomResult = await roomController.initAddRoom({ body: { u1_id: u_id } });
        if (!roomResult.success) {
            console.error('방 생성 실패:', roomResult.error);
            return res.status(500).json({ message: '회원가입은 완료되었으나 방 생성에 실패했습니다.' });
        }

      } else {
        console.log(`Keycloak 사용자가 이미 DB에 존재함: ${u_id}`);
      }
  
      res.status(200).json({ success: true, user });
    } catch (err) {
      console.error('사용자 등록 오류:', err);
      res.status(500).json({ success: false, message: '사용자 등록 중 오류 발생' });
    }
};

const {
    KEYCLOAK_ADMIN_USER,
    KEYCLOAK_ADMIN_PASS,
    KEYCLOAK_BASE_URL,
    KEYCLOAK_REALM,
    KEYCLOAK_CLIENT_ID,
  } = process.env;

exports.deleteAccountFromKeycloak = async (req, res) => {
    try {
        // 🔐 Keycloak 토큰에서 사용자 정보 추출
        const userInfo = req.kauth.grant.access_token.content;
        const username = userInfo.preferred_username;

        // 1. Keycloak 관리자 토큰 발급
        const tokenRes = await axios.post(
            `${KEYCLOAK_BASE_URL}/realms/master/protocol/openid-connect/token`,
            new URLSearchParams({
                grant_type: 'password',
                client_id: KEYCLOAK_CLIENT_ID,
                username: KEYCLOAK_ADMIN_USER,
                password: KEYCLOAK_ADMIN_PASS
            }),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );

        const adminToken = tokenRes.data.access_token;

        // 2. 사용자 UUID 조회
        const userSearchRes = await axios.get(
            `${KEYCLOAK_BASE_URL}/admin/realms/${KEYCLOAK_REALM}/users`,
            {
                headers: { Authorization: `Bearer ${adminToken}` },
                params: { username }
            }
        );

        if (!userSearchRes.data.length) {
            return res.status(404).json({
                success: false,
                message: 'Keycloak 계정을 찾을 수 없습니다.'
            });
        }

        const kcUserId = userSearchRes.data[0].id;

        // 3. Keycloak 계정 삭제
        await axios.delete(
            `${KEYCLOAK_BASE_URL}/admin/realms/${KEYCLOAK_REALM}/users/${kcUserId}`,
            { headers: { Authorization: `Bearer ${adminToken}` } }
        );

        // 4. 로컬 DB 사용자 삭제
        await User.destroy({ where: { u_id: username } });

        return res.json({
            success: true,
            message: `${username} 계정이 Keycloak 및 DB에서 삭제되었습니다.`
        });
    } catch (err) {
        console.error('Keycloak 계정 삭제 오류:', err.message);
        return res.status(500).json({
            success: false,
            message: '계정 삭제 중 오류 발생',
            error: err.message
        });
    }
};


// ✅ Keycloak 토큰 기반 JWT 발급 API
exports.issueJwtFromKeycloak = async (req, res) => {
    try {
        const keycloakUser = req.kauth.grant.access_token.content;

        const userId = keycloakUser.preferred_username;
        if (!userId) {
            return res.status(400).json({ success: false, message: 'Keycloak 사용자 정보가 없습니다.' });
        }

        // JWT 토큰 생성
        const payload = { userId };
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


// ✅ JWT 기반 로그아웃 로직 (간소화 버전)
exports.logoutToken = async (req, res) => {
    res.clearCookie('token'); // 만약 쿠키 기반이라면 의미 있음
    res.json({ message: '로그아웃 되었습니다.' });
};
