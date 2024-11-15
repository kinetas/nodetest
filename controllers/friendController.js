const IFriend = require('../models/i_friendModel'); // i_friend 모델
const TFriend = require('../models/t_friendModel'); // t_friend 모델

// i_friend 테이블에서 친구 리스트 가져오기
exports.printIFriend = async (req, res) => {
    try {
        const userId = req.session.user.id;

        // i_friend 테이블에서 f_id 리스트 조회
        const iFriends = await IFriend.findAll({ where: { u_id: userId }, attributes: ['f_id'] });

        // 응답으로 데이터 반환
        res.status(200).json({
            message: 'i_friend 리스트 출력 성공',
            iFriends: iFriends.map(friend => friend.f_id),
        });
    } catch (error) {
        console.error('Error fetching i_friend list:', error);
        res.status(500).json({ message: 'i_friend 리스트를 가져오는 중 오류가 발생했습니다.' });
    }
};

// t_friend 테이블에서 요청온 친구 리스트 가져오기
exports.printTFriend = async (req, res) => {
    try {
        const userId = req.session.user.id;

        // t_friend 테이블에서 f_id 리스트 조회
        const tFriends = await TFriend.findAll({ where: { u_id: userId }, attributes: ['f_id'] });

        // 응답으로 데이터 반환
        res.status(200).json({
            message: 't_friend 리스트 출력 성공',
            tFriends: tFriends.map(friend => friend.f_id),
        });
    } catch (error) {
        console.error('Error fetching t_friend list:', error);
        res.status(500).json({ message: 't_friend 리스트를 가져오는 중 오류가 발생했습니다.' });
    }
};