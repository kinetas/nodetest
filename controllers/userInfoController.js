exports.getLoggedInUserId = (req, res) => {
    if (req.session && req.session.user) {
        // 세션에 저장된 u_id 반환
        return res.status(200).json({ u_id: req.session.user.id });
    } else {
        // 세션이 없을 경우
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
};