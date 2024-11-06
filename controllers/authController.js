const User = require('../models/userModel');

exports.login = async (req, res) => {
    const { u_id, u_password } = req.body;

    try {
        // 입력받은 ID와 비밀번호로 사용자 검색
        const user = await User.findOne({
            where: {
                u_id: u_id,
                u_password: u_password
            }
        });

        if (user) {
            res.status(200).json({
                message: 'Login successful',
                user: {
                    id: user.u_id,
                    nickname: user.u_nickname,
                    name: user.u_name,
                    birth: user.u_birth,
                    location: user.u_location
                }
            });
        } else {
            res.status(401).json({ message: 'Invalid credentials' });
        }
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error', error });
    }
};