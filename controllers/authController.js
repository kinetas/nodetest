// User 모델 불러오기
const User = require('../models/userModel'); // 경로를 확인하세요

// 로그인 처리 함수
exports.login = async (req, res) => {
    const { u_id, u_password } = req.body;

    try {
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

        // 로그인 성공 시 응답
        return res.status(200).json({
            message: 'Login successful',
            user: {
                nickname: user.u_nickname,
                name: user.u_name,
                location: user.u_location,
                birth: user.u_birth,
            }
        });
    } catch (error) {
        console.error('로그인 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};