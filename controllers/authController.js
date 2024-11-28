// User 모델 불러오기
const User = require('../models/userModel'); // 경로를 확인하세요

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

        // 비밀번호 일치 여부 확인 (bcrypt 사용) // 수정
        // 입력받은 PW를 동일한 방식으로 암호화 후 비교
        const isMatch = await comparePassword(u_password, user.u_password); // 수정
        if (!isMatch) {
            return res.status(401).json({ message: '비밀번호가 일치하지 않습니다.' });
        }

        // 이미 로그인된 세션이 있는지 확인
        if (user.currentSessionId) {
            // 기존 세션 무효화
            req.sessionStore.destroy(user.currentSessionId, (err) => {
                if (err) {
                    console.error('기존 세션 무효화 오류:', err);
                }
            });
        }

        // 로그인 성공 시 세션에 사용자 정보 저장
        req.session.user = {
            id: user.u_id,
            nickname: user.u_nickname,
            name: user.u_name,
        };

        // 사용자 테이블에 현재 세션 ID 저장
        await user.update({ currentSessionId: req.sessionID });
        
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

        // 회원가입 성공 후 방 생성
        await roomController.initAddRoom({ body: { u1_id: u_id } }, res);

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
    const userId = req.session?.user?.id;
    req.session.destroy(async (err) => {
        if (err) {
            console.error('세션 삭제 오류:', err);
            return res.status(500).json({ message: '로그아웃 중 오류가 발생했습니다.' });
        }

        if (userId) {
            // 데이터베이스에서 currentSessionId 초기화
            await User.update({ currentSessionId: null }, { where: { u_id: userId } });
        }

        res.status(200).json({ success: true, message: '로그아웃 성공' });
    });
};

// // ======== 수정 JWT ============
// // JWT는 로그아웃이 서버에서 필요하지 않음
// exports.logOut = (req, res) => {
//     res.status(200).json({ message: '로그아웃은 클라이언트에서 토큰 삭제로 처리됩니다.' });
// };