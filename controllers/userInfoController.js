const User = require('../models/userModel'); // User 모델 가져오기

exports.getLoggedInUserId = (req, res) => {
    if (req.session && req.session.user) {
        // 세션에 저장된 u_id 반환
        return res.status(200).json({ u_id: req.session.user.id });
    } else {
        // 세션이 없을 경우
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
};

// 현재 로그인 중인 사용자의 u_nickname 반환
exports.getLoggedInUserNickname = async (req, res) => {
    if (req.session && req.session.user) {
        try {
            const user = await User.findOne({
                where: { u_id: req.session.user.id },
                attributes: ['u_nickname'], // u_nickname만 가져오기
            });
            if (user) {
                return res.status(200).json({ u_nickname: user.u_nickname });
            } else {
                return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
            }
        } catch (error) {
            console.error(error);
            return res.status(500).json({ message: '서버 오류가 발생했습니다.' });
        }
    } else {
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
};

// 현재 로그인 중인 사용자의 모든 정보 반환
exports.getLoggedInUserAll = async (req, res) => {
    if (req.session && req.session.user) {
        try {
            const user = await User.findOne({
                where: { u_id: req.session.user.id },
            });
            if (user) {
                return res.status(200).json(user); // 사용자 전체 정보를 반환
            } else {
                return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
            }
        } catch (error) {
            console.error(error);
            return res.status(500).json({ message: '서버 오류가 발생했습니다.' });
        }
    } else {
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
};