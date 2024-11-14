const User = require('../models/userModel'); // User 모델 불러오기

// findUid 함수 정의
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