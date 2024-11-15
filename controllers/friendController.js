// const IFriend = require('../models/i_friendModel'); // i_friend 모델
// const TFriend = require('../models/t_friendModel'); // t_friend 모델

// // i_friend 테이블의 f_id 리스트 출력
// exports.printIFriend = async (req, res) => {
//     try {
//         const iFriends = await IFriend.findAll({
//             attributes: ['f_id'],
//             where: { u_id: req.session.user.id }, // 세션 사용자 ID 기준
//         });
//         const friendList = iFriends.map(friend => friend.f_id);
//         res.json({ success: true, iFriends: friendList });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ success: false, message: 'i_friend 데이터를 불러오는 중 오류가 발생했습니다.' });
//     }
// };

// // t_friend 테이블의 f_id 리스트 출력
// exports.printTFriend = async (req, res) => {
//     try {
//         const tFriends = await TFriend.findAll({
//             attributes: ['f_id'],
//             where: { u_id: req.session.user.id, f_status: 0 }, // 세션 사용자 ID 기준, 상태 0(요청)
//         });
//         const requestList = tFriends.map(friend => friend.f_id);
//         res.json({ success: true, tFriends: requestList });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ success: false, message: 't_friend 데이터를 불러오는 중 오류가 발생했습니다.' });
//     }
// };