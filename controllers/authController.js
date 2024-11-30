// User 모델 불러오기
const User = require('../models/userModel'); // 경로를 확인하세요
const Mission = require('../models/missionModel');
const Room = require('../models/roomModel');

const { hashPassword, comparePassword } = require('../utils/passwordUtils'); // 암호화 모듈 가져오기

const roomController = require('./roomController'); // roomController 가져오기

// 로그인 처리 함수 - 쿠키
exports.login = async (req, res) => {
    const { u_id, u_password } = req.body;

    try {

        console.log('Received login request:', u_id, u_password);

        // 사용자 조회
        const user = await User.findOne({ where: { u_id } });

        // 사용자가 없거나 비밀번호가 일치하지 않는 경우
        if (!user) {
            return res.status(401).json({ message: '존재하지 않는 사용자입니다.' });
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
    
        // 비밀번호 암호화 // 수정
        const hashedPassword = await hashPassword(u_password); // 수정

        // 새 사용자 생성
        const newUser = await User.create({
            u_id,
            u_password: hashedPassword, // 암호화된 비밀번호 저장 // 수정
            u_nickname,
            u_name,
            u_birth,
            u_mail
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
exports.logOut = (req, res) => {
    
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

        // 1. mission 데이터 삭제
        await Mission.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });

        // 2. room 데이터 삭제
        await Room.destroy({ where: { [Op.or]: [{ u1_id: userId }, { u2_id: userId }] } });

        // 3. user 데이터 삭제
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