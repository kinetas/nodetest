// controllers/roomController.js
const Room = require('../models/roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');

// const jwt = require('jsonwebtoken'); // JWT 추가

exports.getRooms = async (req, res) => {
    const u1_id = req.session.user.id;
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
    // const { u2_id } = req.body;
    // const type = "close";
    const { u2_id, roomName, r_type } = req.body; // roomName 추가 <!-- 수정 -->
    const type = r_type || "general"; // 기본값 "general"

    //==========if 오픈채팅방이면 type = "open"======================
    //==========     조건을 뭘로 할 것인지     ======================

    // u1_id와 u2_id가 같으면 initAddRoom 호출
    if (u1_id === u2_id) {
        await exports.initAddRoom({ body: { u1_id } }, res); // initAddRoom 호출
        return; // initAddRoom 호출 후 함수 종료
    }

    try {
        // const roomId = Math.random().toString(36).substr(2, 9); // 방 아이디 랜덤 생성
        
        const roomId = uuidv4();
        if (!uuidValidate(roomId)) {
            console.error("생성된 UUID가 유효하지 않습니다.");
            return; // 또는 throw new Error("유효하지 않은 UUID 생성");
        }

        // 방 이름 처리: 입력된 이름이 없으면 기본값 설정
        const r_title = roomName && roomName.trim() ? roomName.trim() : `${u1_id}-${u2_id}`;

        // await Room.create({ u1_id, u2_id, r_id: roomId, r_title: `${u1_id}-${u2_id}`, r_type: `${type}` });

        // //반대방 생성
        // await Room.create({ u1_id: u2_id, u2_id:u1_id, r_id: roomId, r_title: `${u2_id}-${u1_id}`, r_type: `${type}` });

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
    const { u1_id } = req.body;

    try {
        // 방 생성 로직
        const roomId = uuidv4();
        await Room.create({
            u1_id,
            u2_id: u1_id, // 본인의 방 생성
            r_id: roomId,
            r_title: `${u1_id}의 방`,
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
    const { u2_id } = req.params;
    try {
        await Room.destroy({ where: { u1_id, u2_id } });
        await Room.destroy({ where: { u1_id:u2_id, u2_id:u1_id } });
        res.json({ message: '방이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: `방 삭제 중 ${error}오류가 발생했습니다.` });
    }
};

//방 입장함수
exports.enterRoom = async (req, res) => {
    const { r_id, u2_id } = req.body; // 클라이언트에서 방 ID와 유저 ID를 받아옴
    const u1_id = req.session.user.id;

    try {
        // 방이 존재하는지 확인
        const room = await Room.findOne({
            where: { r_id, u1_id, u2_id }
        });

        if (!room) {
            return res.status(404).json({ message: '해당 방을 찾을 수 없습니다.' });
        }

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