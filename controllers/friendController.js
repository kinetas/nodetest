const IFriend = require('../models/i_friendModel'); // i_friend 모델
const TFriend = require('../models/t_friendModel'); // t_friend 모델

// i_friend 테이블의 f_id 리스트 출력
exports.printIFriend = async (req, res) => {
    try {
        const iFriends = await IFriend.findAll({
            attributes: ['f_id'],
            where: { u_id: req.session.user.id }, // 세션 사용자 ID 기준
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
        const tFriends = await TFriend.findAll({
            attributes: ['u_id', 'f_id'],
            where: { f_status: 0 }, // 상태 0(요청)
        });

        const sentRequests = tFriends
            .filter(friend => friend.u_id === req.session.user.id)
            .map(friend => friend.f_id);

        const receivedRequests = tFriends
            .filter(friend => friend.f_id === req.session.user.id)
            .map(friend => friend.u_id);

        res.json({
            success: true,
            sentRequests,
            receivedRequests,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            success: false,
            message: 't_friend 데이터를 불러오는 중 오류가 발생했습니다.',
        });
    }
};

// 친구 삭제 함수
exports.friendDelete = async (req, res) => {
    const { f_id } = req.body; // 삭제할 친구 ID
    try {
        // u_id와 f_id 관계 삭제
        const result1 = await IFriend.destroy({
            where: {
                u_id: req.session.user.id,
                f_id: f_id,
            },
        });

        // f_id와 u_id 관계 삭제 (양방향 관계)
        const result2 = await IFriend.destroy({
            where: {
                u_id: f_id,
                f_id: req.session.user.id,
            },
        });

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

// 친구 요청 보내기 함수
exports.friendRequestSend = async (req, res) => {
    const { f_id } = req.body; // 친구 요청할 ID
    const u_id = req.session.user.id; // 현재 로그인한 사용자 ID

    try {
        // 기존 친구 요청 확인
        const existingRequest = await TFriend.findOne({
            where: { u_id, f_id },
        });

        const reverseRequest = await TFriend.findOne({
            where: { u_id: f_id, f_id: u_id },
        });

        // 시나리오 1: 상대방이 나에게 요청을 보낸 상태인지 확인
        if (reverseRequest && reverseRequest.f_status === 0) {
            return res.status(400).json({ success: false, message: '상대방의 친구 요청이 이미 와 있습니다.' });
        }

        // 기존 요청이 존재하는 경우
        if (existingRequest) {
            if (existingRequest.f_status === 0) {
                // case 1: 요청 중
                return res.status(400).json({ success: false, message: '이미 요청 중입니다.' });
            } else if (existingRequest.f_status === 1) {
                // case 2: 수락 상태
                const isFriend = await IFriend.findOne({
                    where: { u_id, f_id },
                });

                const isFriendReverse = await IFriend.findOne({
                    where: { u_id: f_id, f_id: u_id },
                });

                if (isFriend && isFriendReverse) {
                    // case 2-1: 이미 친구인 경우
                    return res.status(400).json({ success: false, message: '이미 친구입니다.' });
                } else {
                    // case 2-2: 친구가 아닌 경우(친구 삭제 후 다시 요청)
                    await TFriend.update(
                        { f_status: 0, f_create: new Date() }, // 상태를 요청으로 변경
                        { where: { u_id, f_id } }
                    );

                    return res.json({ success: true, message: '친구 요청이 성공적으로 다시 전송되었습니다.' });
                }
            } else if (existingRequest.f_status === 2) {
                // case 3: 거절 상태
                return res.status(400).json({ success: false, message: `${f_id} 님이 요청을 거절한 상태입니다.` });
            }
        }

        // 시나리오 2: 상대방이 요청하지 않았고 기존 상태가 없는 경우 새 요청 생성
        if (!existingRequest && !reverseRequest) {
            const request = await TFriend.create({
                u_id,
                f_id,
                f_create: new Date(),
                f_status: 0, // 0 = 요청
            });

            return res.json({ success: true, message: '친구 요청이 성공적으로 전송되었습니다.' });
        }

        // 요청이 비정상적으로 처리되지 않은 경우
        return res.status(500).json({ success: false, message: '친구 요청 처리 중 예상치 못한 오류가 발생했습니다.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: `친구 요청 전송 중 오류 (${error})가 발생했습니다.` });
    }
};

// 친구 요청 수락 함수
exports.friendRequestAccept = async (req, res) => {
    const { f_id } = req.body; // 친구 요청한 ID
    try {
        // i_friend 테이블에 저장
        await IFriend.create({
            u_id: req.session.user.id,
            f_id: f_id,
        });

        await IFriend.create({
            u_id: f_id,
            f_id: req.session.user.id,
        });

        // t_friend 테이블 상태 업데이트
        const result = await TFriend.update(
            { f_status: 1 }, // 1 = 수락
            {
                where: {
                    u_id: f_id,
                    f_id: req.session.user.id,
                },
            }
        );

        if (result[0] > 0) {
            res.json({ success: true, message: '친구 요청이 수락되었습니다.' });
        } else {
            res.status(404).json({ success: false, message: '친구 요청을 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: `친구 요청 수락 중 오류 (${error})가 발생했습니다.` });
    }
};

// 친구 요청 거절 함수
exports.friendRequestReject = async (req, res) => {
    const { f_id } = req.body; // 친구 요청한 ID
    try {
        const result = await TFriend.update(
            { f_status: 2 }, // 2 = 거절
            {
                where: {
                    u_id: f_id,
                    f_id: req.session.user.id,
                },
            }
        );

        if (result[0] > 0) {
            res.json({ success: true, message: '친구 요청이 거절되었습니다.' });
        } else {
            res.status(404).json({ success: false, message: '친구 요청을 찾을 수 없습니다.' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: '친구 요청 거절 중 오류가 발생했습니다.' });
    }
};