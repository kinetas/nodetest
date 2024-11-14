const User = require('../models/userModel'); // User 모델 불러오기
const { hashPassword } = require('../utils/passwordUtils'); // 비밀번호 해시 함수 불러오기

// 아이디 찾기 함수
exports.findUid = async (req, res) => {
    const { name, nickname, birthdate, email } = req.body;

    try {
        // 생년월일을 Date 형식으로 변환
        const year = parseInt(birthdate.slice(0, 2), 10) + 2000; // 2000년대 출생 가정
        const month = parseInt(birthdate.slice(2, 4), 10) - 1; // 월은 0부터 시작하므로 -1
        const day = parseInt(birthdate.slice(4, 6), 10);
        const birthDate = new Date(year, month, day);

        // DB에서 조건에 맞는 사용자 조회
        const user = await User.findOne({
            where: {
                u_name: name,
                u_nickname: nickname,
                u_birth: birthDate,
                u_mail: email
            }
        });

        // 사용자가 존재하면 u_id를 응답, 없으면 오류 메시지
        if (user) {
            return res.status(200).json({ userId: user.u_id });
        } else {
            return res.status(404).json({ message: '일치하는 사용자가 없습니다.' });
        }
    } catch (error) {
        console.error('사용자 조회 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
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
            return res.status(200).json({ message: '비밀번호가 성공적으로 변경되었습니다.' });
        } else {
            return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error('비밀번호 변경 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};