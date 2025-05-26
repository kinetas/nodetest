//=============================Token=============================
const IFriend = require('../model/i_friendModel');
const TFriend = require('../model/t_friendModel');
// const notificationController = require('../controllers/notificationController');
const getCurrentUserId = (req) => {
    return req.currentUserId || null; // app.js에서 설정된 currentUserId 사용
  };

// i_friend 테이블의 f_id 리스트 출력
exports.printIFriend = async (req, res) => {
    try {
        const u_id = getCurrentUserId(req);
        const iFriends = await IFriend.findAll({
            attributes: ['f_id'],
            where: { u_id },
        });
        const friendList = iFriends.map(friend => friend.f_id);
        res.json({ success: true, iFriends: friendList });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'i_friend 데이터를 불러오는 중 오류가 발생했습니다.' });
    }
};

// t_friend 테이블의 요청 리스트 출력
exports.printTFriend = async (req, res) => {
    try {
        const u_id = getCurrentUserId(req);
        const tFriends = await TFriend.findAll({
            attributes: ['u_id', 'f_id'],
            where: { f_status: 0 },
        });

        const sentRequests = tFriends.filter(friend => friend.u_id === u_id).map(friend => friend.f_id);
        const receivedRequests = tFriends.filter(friend => friend.f_id === u_id).map(friend => friend.u_id);
        // const sentRequests = tFriends.filter(friend => friend.u_id === req.kauth?.grant?.access_token?.content?.preferred_username).map(friend => friend.f_id);
        // const receivedRequests = tFriends.filter(friend => friend.f_id === req.kauth?.grant?.access_token?.content?.preferred_username).map(friend => friend.u_id);

        res.json({ success: true, sentRequests, receivedRequests });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 't_friend 데이터를 불러오는 중 오류가 발생했습니다.' });
    }
};

// 친구 삭제
exports.friendDelete = async (req, res) => {
    const { f_id } = req.body;
    const u_id = req.currentUserId;

    try {
        const result1 = await IFriend.destroy({ where: { u_id, f_id } });
        const result2 = await IFriend.destroy({ where: { u_id: f_id, f_id: u_id } });

        if (result1 > 0 && result2 > 0) {
            res.json({ success: true, message: '친구가 성공적으로 삭제되었습니다.' });
        } else {
            res.status(404).json({ success: false, message: '삭제할 친구를 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: '친구 삭제 중 오류가 발생했습니다.' });
    }
};

// 친구 요청 보내기
exports.friendRequestSend = async (req, res) => {
    const { f_id } = req.body;
    const u_id = req.currentUserId;

    try {
        if (u_id === f_id) {
            return res.status(400).json({ success: false, message: '자기 자신에게는 요청을 보낼 수 없습니다.' });
        }

        const existingRequest = await TFriend.findOne({ where: { u_id, f_id } });
        const reverseRequest = await TFriend.findOne({ where: { u_id: f_id, f_id: u_id } });

        if (reverseRequest && reverseRequest.f_status === 0) {
            return res.status(400).json({ success: false, message: '상대방이 이미 요청을 보낸 상태입니다.' });
        }

        if (existingRequest) {
            if (existingRequest.f_status === 0) {
                return res.status(400).json({ success: false, message: '이미 요청 중입니다.' });
            } else if (existingRequest.f_status === 1) {
                const isFriend = await IFriend.findOne({ where: { u_id, f_id } });
                const isFriendReverse = await IFriend.findOne({ where: { u_id: f_id, f_id: u_id } });

                if (isFriend && isFriendReverse) {
                    return res.status(400).json({ success: false, message: '이미 친구입니다.' });
                } else {
                    await TFriend.update({ f_status: 0, f_create: new Date() }, { where: { u_id, f_id } });
                    // const notify = await notificationController.sendFriendRequestNotification(u_id, f_id);
                    // if (!notify) return res.status(400).json({ success: false, message: '알림 실패' });
                    return res.json({ success: true, message: '다시 요청을 보냈습니다.' });
                }
            } else if (existingRequest.f_status === 2) {
                await TFriend.update({ f_status: 0, f_create: new Date() }, { where: { u_id, f_id } });
                // const notify = await notificationController.sendFriendRequestNotification(u_id, f_id);
                // if (!notify) return res.status(400).json({ success: false, message: '알림 실패' });
                return res.json({ success: true, message: '다시 요청을 보냈습니다.' });
            }
        }

        if (!existingRequest && (!reverseRequest || reverseRequest.f_status !== 0)) {
            await TFriend.create({ u_id, f_id, f_create: new Date(), f_status: 0 });
            // const notify = await notificationController.sendFriendRequestNotification(u_id, f_id);
            // if (!notify) return res.status(400).json({ success: false, message: '알림 실패' });
            return res.json({ success: true, message: '친구 요청이 성공적으로 전송되었습니다.' });
        }

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: `친구 요청 오류: ${error.message}` });
    }
};

// 친구 요청 수락
exports.friendRequestAccept = async (req, res) => {
    const { f_id } = req.body;
    const u_id = req.currentUserId;

    try {
        const existingRequest = await TFriend.findOne({ where: { u_id: f_id, f_id: u_id, f_status: 0 } });

        if (!existingRequest) {
            return res.status(404).json({ success: false, message: '친구 요청 없음' });
        }

        const alreadyFriend = await IFriend.findOne({ where: { u_id, f_id } }) ||
                              await IFriend.findOne({ where: { u_id: f_id, f_id: u_id } });

        if (alreadyFriend) {
            return res.status(400).json({ success: false, message: '이미 친구입니다.' });
        }

        await IFriend.bulkCreate([{ u_id, f_id }, { u_id: f_id, f_id: u_id }]);
        await TFriend.update({ f_status: 1 }, { where: { u_id: f_id, f_id: u_id } });

        // const notify = await notificationController.sendFriendAcceptNotification(u_id, f_id);
        // if (!notify) return res.status(400).json({ success: false, message: '알림 실패' });

        res.json({ success: true, message: '친구 요청 수락 완료' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: `수락 오류: ${error.message}` });
    }
};

// 친구 요청 거절
exports.friendRequestReject = async (req, res) => {
    const { f_id } = req.body;
    const u_id = req.currentUserId;

    try {
        const result = await TFriend.update({ f_status: 2 }, { where: { u_id: f_id, f_id: u_id } });

        if (result[0] > 0) {
            res.json({ success: true, message: '요청을 거절했습니다.' });
        } else {
            res.status(404).json({ success: false, message: '요청을 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: `거절 오류: ${error.message}` });
    }
};
