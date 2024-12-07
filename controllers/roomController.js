// controllers/roomController.js
const Room = require('../models/roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize'); // [추가됨] Sequelize 연산자 추가

// const jwt = require('jsonwebtoken'); // JWT 추가

exports.getRooms = async (req, res) => {
    const u1_id = req.session.user.id;
    if (!u1_id) {
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
    const rooms = await Room.findAll({
        where: { u1_id }
    });
    console.log(JSON.stringify({ rooms }));
    res.json({ rooms });
};


// // ===== JWT 기반 인증 =====
// exports.getRooms = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const userId = decoded.id;

//         const rooms = await Room.findAll({
//             where: { u1_id: userId },
//         });

//         res.json({ rooms });
//     } catch (error) {
//         return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
//     }
// };

exports.addRoom = async (req, res) => {
    const u1_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
    const { u2_id, roomName, r_type } = req.body;
    const type = r_type || "general"; // 기본값 "general"

    try {

        // [추가됨] 기존 방이 존재하는지 확인
        const existingRoom = await Room.findOne({
            where: {
                [Op.or]: [
                    { u1_id, u2_id, r_type: type },
                    { u1_id: u2_id, u2_id: u1_id, r_type: type }
                ]
            }
        });

        if (existingRoom) {
            return res.status(400).json({ success: false, message: '해당 타입의 방이 이미 존재합니다.' });
        }
        
        
        // u1_id와 u2_id가 같으면 initAddRoom 호출
        if (u1_id === u2_id) {
            await exports.initAddRoom({ body: { u1_id, roomName } }, res); // initAddRoom 호출
            return; // initAddRoom 호출 후 함수 종료
        }

        const roomId = uuidv4();
        if (!uuidValidate(roomId)) {
            console.error("생성된 UUID가 유효하지 않습니다.");
            return; // 또는 throw new Error("유효하지 않은 UUID 생성");
        }

        // 방 이름 처리: 입력된 이름이 없으면 기본값 설정
        const r_title = roomName && roomName.trim() ? roomName.trim() : `${u1_id}-${u2_id}`;

        // 방 생성
        await Room.create({ u1_id, u2_id, r_id: roomId, r_title, r_type: type });
        // 반대방 생성
        await Room.create({ u1_id: u2_id, u2_id: u1_id, r_id: roomId, r_title, r_type: type });

        res.json({ message: '방이 성공적으로 추가되었습니다.' });
    } catch (error) {
        console.error(error); // 추가로 오류 로깅
        res.status(500).json({ message: `방 추가 중 ${error}오류가 발생했습니다.` });
    }
};

// // ===== JWT 기반 방 추가 함수 =====
// exports.addRoom = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const u1_id = decoded.id; // 토큰에서 u1_id 추출
//         const { u2_id, r_type } = req.body;
//         const type = r_type || 'close';

//         const roomId = uuidv4();
//         if (!uuidValidate(roomId)) {
//             console.error('생성된 UUID가 유효하지 않습니다.');
//             return res.status(500).json({ message: '유효하지 않은 UUID 생성' });
//         }

//         await Room.create({ u1_id, u2_id, r_id: roomId, r_title: `${u1_id}-${u2_id}`, r_type: type });
//         await Room.create({ u1_id: u2_id, u2_id: u1_id, r_id: roomId, r_title: `${u2_id}-${u1_id}`, r_type: type });

//         res.json({ message: '방이 성공적으로 추가되었습니다.' });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ message: '방 추가 중 오류가 발생했습니다.' });
//     }
// };


// exports.initAddRoom = async (req, res) => {
//     const { u1_id } = req.body;

//     const roomId = uuidv4();
//     if (!uuidValidate(roomId)) {
//         console.error("생성된 UUID가 유효하지 않습니다.");
//         return; // 또는 throw new Error("유효하지 않은 UUID 생성");
//     }

//     try {
//         await Room.create({ u1_id, u2_id:u1_id, r_id:roomId, r_title: `${u1_id}`, r_type:"general" });
//         res.json({ message: '방이 성공적으로 추가되었습니다.' });
//     } catch (error) {
//         console.error(error); // 추가로 오류 로깅
//         res.status(500).json({ message: `방 추가 중 ${error}오류가 발생했습니다.` });
//     }
// };

// 방 생성 함수 ================추가=========================
exports.initAddRoom = async (req) => {
    const { u1_id, roomName } = req.body;

    try {
        // 방 생성 로직
        const roomId = uuidv4();
        // 방 이름 처리: 입력된 이름이 없으면 기본값 설정
        const r_title = roomName && roomName.trim() ? roomName.trim() : `${u1_id}의 방`;
        await Room.create({
            u1_id,
            u2_id: u1_id, // 본인의 방 생성
            r_id: roomId,
            // r_title: `${u1_id}의 방`,
            r_title: r_title,
            r_type: 'general',
        });

        console.log(`방이 성공적으로 생성되었습니다: ${roomId}`);
        return { success: true, message: '방 생성 완료' }; // 결과만 반환
    } catch (error) {
        console.error('방 생성 오류:', error);
        return { success: false, error: '방 생성 실패' }; // 오류 반환
    }
};

//방 삭제
exports.deleteRoom = async (req, res) => {
    const u1_id = req.session.user.id;
    const { u2_id, r_type } = req.params;
    try {
        await Room.destroy({ where: { u1_id, u2_id, r_type } });
        await Room.destroy({ where: { u1_id:u2_id, u2_id:u1_id, r_type } });
        res.json({ message: '방이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: `방 삭제 중 ${error}오류가 발생했습니다.` });
    }
};

//방 입장함수
exports.enterRoom = async (req, res) => {
    const { r_id, u2_id} = req.body; // 클라이언트에서 방 ID와 유저 ID를 받아옴
    const u1_id = req.session.user.id;

    try {
        // 방이 존재하는지 확인
        const room = await Room.findOne({
            where: { r_id, u1_id, u2_id}
        });

        if (!room) {
            return res.status(404).json({ message: '해당 방을 찾을 수 없습니다.' });
        }
         // 방에 입장하면서 메시지의 is_read 값을 업데이트
        const updatedCount = await RMessage.update(
            { is_read: 0 }, // 읽음 처리
            {
                where: {
                    r_id,           // 해당 채팅방
                    is_read: 1      // 읽지 않은 메시지만 처리
                }
            }
        );
        // 방 입장에 필요한 다른 로직 추가 (예: 로그 기록)
        console.log(JSON.stringify({ message: '방에 성공적으로 입장했습니다.', room }));
        res.json({ message: '방에 성공적으로 입장했습니다.', room });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: `방 입장 중 ${error} 오류가 발생했습니다.` });
    }
};

// // ===== JWT 기반 방 삭제 함수 =====
// exports.deleteRoom = async (req, res) => {
//     const token = req.headers.authorization?.split(' ')[1];
//     if (!token) {
//         return res.status(401).json({ message: '로그인이 필요합니다.' });
//     }

//     try {
//         const decoded = jwt.verify(token, process.env.JWT_SECRET);
//         const u1_id = decoded.id; // 토큰에서 u1_id 추출
//         const { u2_id } = req.params;

//         await Room.destroy({ where: { u1_id, u2_id } });
//         await Room.destroy({ where: { u1_id: u2_id, u2_id: u1_id } });

//         res.json({ message: '방이 성공적으로 삭제되었습니다.' });
//     } catch (error) {
//         res.status(500).json({ message: '방 삭제 중 오류가 발생했습니다.' });
//     }
// };


// 방 이름 변경 함수 추가
exports.updateRoomName = async (req, res) => {
    const u1_id = req.session.user.id; // 현재 로그인된 사용자 ID
    const { u2_id, newRoomName, r_type } = req.body; // 입력받은 유저 ID와 새로운 방 이름

    try {
        const updated = await Room.update(
            { r_title: newRoomName },
            { where: { u1_id, u2_id, r_type } }
        );

        if (updated[0] === 0) {
            return res.status(404).json({ message: "해당 방을 찾을 수 없습니다." });
        }

        return res.json({ message: "방 이름이 성공적으로 변경되었습니다." });
    } catch (error) {
        console.error("방 이름 변경 중 오류:", error);
        res.status(500).json({ message: "방 이름 변경 중 오류가 발생했습니다." });
    }
};