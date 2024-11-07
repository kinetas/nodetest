// User 모델 불러오기
const User = require('../models/userModel'); // 경로를 확인하세요

// 로그인 처리 함수
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

        // 비밀번호 일치 여부 확인 (단순 문자열 비교)
        if (u_password !== user.u_password) {
            return res.status(401).json({ message: '비밀번호가 일치하지 않습니다.' });
        }
        req.session.user = {
            id: user.u_id,
            nickname: user.u_nickname,
            name: user.u_name,
        };
        // 로그인 성공 시 응답
        return res.status(200).json({
            message: 'Login successful',
            user: {
                nickname: user.u_nickname,
                name: user.u_name,
                location: user.u_location,
                birth: user.u_birth,
            },
            redirectUrl: '/dashboard' // 리디렉션할 URL
        });
    } catch (error) {
        console.error('로그인 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};
exports.register = async (req, res) => {
    const { u_id, u_password, u_nickname, u_name } = req.body; // 요청 바디에서 사용자 정보 가져오기
    
    try {
        // 이미 존재하는 사용자 확인
        const existingUser = await User.findOne({ where: { u_id } });
        if (existingUser) {
            return res.status(400).json({ message: '이미 사용 중인 아이디입니다.' });
        }
    
        // 새 사용자 생성
        const newUser = await User.create({
            u_id,
            u_password, // 아직 암호화하지 않음
            u_nickname,
            u_name,
        });
    
        // 성공 응답
        res.status(201).json({
            message: '회원가입이 완료되었습니다.',
            user: {
                id: newUser.u_id,
                nickname: newUser.u_nickname,
                name: newUser.u_name,
            },
        });
    } catch (error) {
        console.error('회원가입 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};