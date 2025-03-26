const User = require('../models/userModel'); // User 모델 불러오기
const { hashPassword } = require('../utils/passwordUtils'); // 비밀번호 해시 함수 불러오기

// const jwt = require('jsonwebtoken'); // JWT 추가

// 아이디 찾기 함수
exports.findUid = async (req, res) => {
    const { name, nickname, birthdate, email } = req.body;

    try {

        // DB에서 조건에 맞는 사용자 조회
        const user = await User.findOne({
            where: {
                u_name: name,
                u_nickname: nickname,
                u_birth: birthdate,
                u_mail: email
            }
        });

        // 사용자가 존재하면 u_id를 응답, 없으면 오류 메시지
        if (user) {
            console.log(JSON.stringify({ userId: user.u_id }));
            return res.status(200).json({ userId: user.u_id });
        } else {
            console.log(JSON.stringify({ message: '일치하는 사용자가 없습니다.' }));
            return res.status(404).json({ message: '일치하는 사용자가 없습니다.' });
        }
    } catch (error) {
        console.error('사용자 조회 오류:', error);
        res.status(500).json({ message: `서버 오류 (${error})가 발생했습니다.` });
    }
};

// 비밀번호 변경 함수
exports.changePassword = async (req, res) => {
    const { userId, newPassword } = req.body; // userId와 새 비밀번호 입력받기

    try {
        // 입력받은 새 비밀번호를 해시화
        const hashedPassword = await hashPassword(newPassword);

        // 해당 userId의 비밀번호를 새 비밀번호로 업데이트
        const result = await User.update(
            { u_password: hashedPassword },
            { where: { u_id: userId } }
        );

        // 업데이트 성공 시 응답
        if (result[0] > 0) {
            console.log(JSON.stringify({ message: '비밀번호가 성공적으로 변경되었습니다.' }));
            return res.status(200).json({ message: '비밀번호가 성공적으로 변경되었습니다.' });
        } else {
            console.log(JSON.stringify({ message: '사용자를 찾을 수 없습니다.' }));
            return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error('비밀번호 변경 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};

// // ===== JWT 기반 비밀번호 변경 =====
// exports.changePassword = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const userId = decoded.id;
//         const { newPassword } = req.body;

//         // 비밀번호 변경 로직
//         res.json({ message: '비밀번호가 성공적으로 변경되었습니다.' });
//     } catch (error) {
//         res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//     }
// };