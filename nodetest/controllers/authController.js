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
            idToken: id_token
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
        const redirectUri = 'http://27.113.11.48:3000/dashboard';
        // const redirectUri = 'myapp://login-callback';
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


// 로그인 처리 함수 - 쿠키
exports.login = async (req, res) => {
    const { u_id, u_password, token } = req.body;// 여기에 디바이스 토큰 추가
    // const { u_id, u_password } = req.body;

    try {

        console.log('Received login request:', u_id, u_password);

        // 사용자 조회
        const user = await User.findOne({ where: { u_id } });

        // 사용자가 없거나 비밀번호가 일치하지 않는 경우
        if (!user) {
            return res.status(401).json({ message: '존재하지 않는 사용자입니다.' });
        }

        if (!token) {
            return res.status(401).json({ message: '받은 디바이스 토큰이 없습니다.' });
        }

        // 비밀번호 일치 여부 확인 (bcrypt 사용)
        // 입력받은 PW를 동일한 방식으로 암호화 후 비교
        const isMatch = await comparePassword(u_password, user.u_password);
        if (!isMatch) {
            return res.status(401).json({ message: '비밀번호가 일치하지 않습니다.' });
        }

        // // 기존 세션 처리 - ====================추가=============================
        // if (user.session_id) {
        //     console.log('[DEBUG] 기존 세션 삭제 요청:', user.session_id);
        //     req.sessionStore.destroy(user.session_id, (err) => {
        //         if (err) {
        //             console.error('기존 세션 삭제 오류:', err);
        //         }
        //     });
        // }

        // 로그인 성공 시 세션에 사용자 정보 저장
        req.session.user = {
            id: user.u_id,
            nickname: user.u_nickname,
            name: user.u_name,
        };
        // console.log('[DEBUG] 새로운 세션 설정:', req.session); // 추가

        // 디바이스 토큰 저장
        await User.update(
            { token: token },
            { where: { u_id } }
        );

        // // 업데이트 성공 시 응답
        // if (updateToken[0] > 0) {
        //     console.log(JSON.stringify({ message: '디바이스 토큰이 성공적으로 갱신되었습니다.' }));
        // } else {
        //     console.log(JSON.stringify({ message: '받은 토큰이 없습니다.' }));
        //     return res.status(404).json({ message: '받은 토큰이 없습니다.' });
        // }

        // 로그인 성공 시 응답
        return res.status(200).json({
            message: 'Login successful',
            user: {
                nickname: user.u_nickname,
                name: user.u_name,
                birth: user.u_birth,
                mail: user.u_mail,
            },
            redirectUrl: '/dashboard' // 리디렉션할 URL
        });
    } catch (error) {
        console.error('로그인 오류:', error);
        res.status(500).json({ message: `서버 ${error}오류가 발생했습니다.` });
    }
};

// // ======== 수정 JWT ============
// exports.login = async (req, res) => {
//     const { u_id, u_password } = req.body;
//     try {
//         const user = await User.findOne({ where: { u_id } });
//         if (!user || !(await comparePassword(u_password, user.u_password))) {
//             return res.status(401).json({ message: '아이디 또는 비밀번호가 일치하지 않습니다.' });
//         }

//         // JWT 토큰 생성
//         const token = jwt.sign({ id: user.u_id, nickname: user.u_nickname }, process.env.JWT_SECRET, { expiresIn: '1d' });

//         res.status(200).json({
//             message: 'Login successful',
//             token,
//             user: { id: user.u_id, nickname: user.u_nickname },
//         });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ message: '서버 오류' });
//     }
// };


// 회원가입 함수
exports.register = async (req, res) => {
    req.session.destroy(); // 세션 초기화
    const { u_id, u_password, u_nickname, u_name, u_birth, u_mail } = req.body; // 요청 바디에서 사용자 정보 가져오기
    
    try {
        // 이미 존재하는 사용자 확인
        const existingUser = await User.findOne({ where: { u_id } });
        if (existingUser) {
            return res.status(400).json({ message: '이미 사용 중인 아이디입니다.' });
        }

        // 이미 존재하는 사용자 확인 (닉네임)
        const existingNickname = await User.findOne({ where: { u_nickname } });
        if (existingNickname) {
            return res.status(400).json({ message: '이미 사용 중인 닉네임입니다.' });
        }

        // 생년월일이 현재 시간보다 미래인 경우 에러 반환
        const birthDate = new Date(u_birth);
        const now = new Date();
        if (birthDate > now) {
            return res.status(400).json({ message: '생년월일을 올바르게 입력하세요.' });
        }

        // 이메일 중복 검사
        const existingMail = await User.findOne({where: { u_mail } });
        if (existingMail) {
            return res.status(400).json({ message: '이미 사용 중인 이메일입니다.' });
        }
    
        // 비밀번호 암호화 // 수정
        const hashedPassword = await hashPassword(u_password); // 수정

        // 새 사용자 생성
        const newUser = await User.create({
            u_id,
            u_password: hashedPassword, // 암호화된 비밀번호 저장 // 수정
            u_nickname,
            u_name,
            u_birth,
            u_mail,
            // reward: 0
        });

        // // 회원가입 성공 후 방 생성
        // await roomController.initAddRoom({ body: { u1_id: u_id } }, res);
        // 방 생성 (응답 처리 없이 결과만 확인)
        const roomResult = await roomController.initAddRoom({ body: { u1_id: u_id } });
        if (!roomResult.success) {
            console.error('방 생성 실패:', roomResult.error);
            return res.status(500).json({ message: '회원가입은 완료되었으나 방 생성에 실패했습니다.' });
        }

        console.log(JSON.stringify({
            message: '회원가입이 완료되었습니다.',
            user: {
                id: newUser.u_id,
                nickname: newUser.u_nickname,
                name: newUser.u_name,
                birth: newUser.u_birth,
                mail: newUser.u_mail
            },
        }));
        // 성공 응답
        res.status(201).json({
            message: '회원가입이 완료되었습니다.',
            user: {
                id: newUser.u_id,
                nickname: newUser.u_nickname,
                name: newUser.u_name,
                birth: newUser.u_birth,
                mail: newUser.u_mail
            },
        });
    } catch (error) {
        console.error('회원가입 오류:', error);
        res.status(500).json({ message: `서버 오류 (${error}) 가 발생했습니다.` });
    }
};

// 로그아웃 함수
exports.logOut = async (req, res) => {
    
    const u_id = req.session.user.id; // 세션에서 사용자 ID 가져오기

    // 디바이스 토큰 삭제
    await User.update(
        { token: null },
        { where: { u_id } }
    );


    // // 디바이스 토큰 삭제
    // const updateToken = await User.update(
    //     { token: null },
    //     { where: { u_id } }
    // );

    // if(!updateToken){
    //     return res.status(401).json({ message: '세션에 유저 아이디가 없습니다.' });
    // }

    req.session.destroy((err) => {
        if (err) {
            console.error('세션 삭제 오류:', err);
            return res.status(500).json({ message: '로그아웃 중 오류가 발생했습니다.' });
        }

        res.status(200).json({ success: true, message: '로그아웃 성공' });
    });

    // //========================추가=======================================
    // const userId = req.session.user?.id;

    // if (!userId) {
    //     return res.status(401).json({ message: '로그인이 필요합니다.' });
    // }

    // req.session.destroy(async (err) => {
    //     if (err) {
    //         console.error('세션 삭제 오류:', err);
    //         return res.status(500).json({ message: '로그아웃 중 오류가 발생했습니다.' });
    //     }

    //     try {
    //         const user = await User.findOne({ where: { u_id: userId } });
    //         if (user) {
    //             user.session_id = null;
    //             await user.save();
    //         }
    //         res.status(200).json({ success: true, message: '로그아웃 성공' });
    //     } catch (error) {
    //         console.error('로그아웃 처리 중 오류:', error);
    //         res.status(500).json({ message: '로그아웃 처리 중 서버 오류가 발생했습니다.' });
    //     }
    // });
};

// // ======== 수정 JWT ============
// // JWT는 로그아웃이 서버에서 필요하지 않음
// exports.logOut = (req, res) => {
//     res.status(200).json({ message: '로그아웃은 클라이언트에서 토큰 삭제로 처리됩니다.' });
// };


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


//=============================Token========================

exports.loginToken = async (req, res) => {
    console.time("LoginResponseTime"); // 시작 지점
    try {
        const { userId, password } = req.body;

        // 사용자 조회
        const user = await User.findOne({ where: { u_id: userId } });

        if (!user) {
            return res.status(400).json({ success: false, message: '가입되지 않은 아이디입니다.' });
        }

        const isMatched = await comparePassword(password, user.u_password);

        if (!isMatched) {
            return res.status(401).json({ success: false, message: '비밀번호가 일치하지 않습니다.' });
        }

        // 생년월일 처리: 일반 버전과 DP 버전 선택 가능하게
        let birthDate;
        const useDP = false; // ✅ 실험 시 여기만 true/false 바꿔서 비교 가능

        if (useDP) {
            const birth = new Date(user.u_birth);
            const birthDays = Math.floor(birth.getTime() / (1000 * 60 * 60 * 24));
            const epsilon = 0.9;
            const noisyDays = Math.floor(addLaplaceNoise(birthDays, epsilon));
            birthDate = new Date(noisyDays * 24 * 60 * 60 * 1000);
        } else {
            birthDate = user.u_birth;
        }

        const payload = {
            userId: user.u_id,
            birth: birthDate.toISOString().split('T')[0],
        };

        const token = generateToken(payload);

        console.timeEnd("LoginResponseTime"); // 응답 시간 측정 끝

        return res.status(200).json({
            success: true,
            message: '성공적으로 로그인 되었습니다.',
            token,
            user: {
                u_id: user.u_id,
                u_name: user.u_name,
                birth_sent: birthDate.toISOString().split('T')[0],
            }
        });

        // // JWT 페이로드 설정
        // const payload = {
        //     userId: user.u_id,  // 클레임 이름은 loginRequired.js와 일치시켜야 함
        // };

        // // 토큰 생성
        // const token = generateToken(payload); // 1시간 유효 토큰 발급

        // // 클라이언트로 토큰 전달
        // return res.status(200).json({
        //     success: true,
        //     message: '성공적으로 로그인 되었습니다.',
        //     token, // ✅ 클라이언트는 이걸 localStorage에 저장
        //     user: {
        //         u_id: user.u_id,
        //         u_name: user.u_name,
        //         // 추가 정보 필요한 경우 여기에 포함
        //     }
        // });

    } catch (error) {
        console.error('loginToken error:', error);
        return res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
};

// 로그아웃 로직 구현
// exports.logoutToken = async (req, res) => { 
//     const token = req.headers.authorization?.split(" ")[1];

//     if (!token) {
//         res.status(400).json({ message: '토큰이 없습니다. 로그인 상태를 확안하세요.' });
//         return;
//     }

//     const decoded = jwt.verify(token, secretKey);

//     if (!decoded) {
//         res.status(401).json({ message: '잘못된 토큰입니다. 로그인 상태를 확인하세요.' });
//         return;
//     }

//     res.clearCookie('token'); // 로그아웃시 쿠키 삭제
//     res.json({ message: '로그아웃 되었습니다.' });
// };
// ✅ JWT 기반 로그아웃 로직 (간소화 버전)
exports.logoutToken = async (req, res) => {
    res.clearCookie('token'); // 만약 쿠키 기반이라면 의미 있음
    res.json({ message: '로그아웃 되었습니다.' });
};

// ✅ JWT 기반 계정 탈퇴 함수
exports.deleteAccountToken = async (req, res) => {
    const userId = req.currentUserId; // ✅ JWT로부터 추출한 사용자 ID

    if (!userId) {
        return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
    }

    try {
        // 1. 메시지 삭제
        await RMessage.destroy({
            where: {
                [Op.or]: [{ u1_id: userId }, { u2_id: userId }]
            }
        });

        // 2. 미션 삭제
        await Mission.destroy({
            where: {
                [Op.or]: [{ u1_id: userId }, { u2_id: userId }]
            }
        });

        // 3. 방 삭제
        await Room.destroy({
            where: {
                [Op.or]: [{ u1_id: userId }, { u2_id: userId }]
            }
        });

        // 4. 유저 삭제
        const deleted = await User.destroy({ where: { u_id: userId } });

        if (deleted) {
            return res.status(200).json({
                success: true,
                message: '계정이 성공적으로 삭제되었습니다.'
            });
        } else {
            return res.status(404).json({
                success: false,
                message: '사용자를 찾을 수 없습니다.'
            });
        }
    } catch (error) {
        console.error('계정 삭제 오류:', error);
        return res.status(500).json({
            success: false,
            message: `서버 오류(${error.message})가 발생했습니다.`
        });
    }
};