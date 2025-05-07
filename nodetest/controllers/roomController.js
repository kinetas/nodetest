//==========================================token============================================
const Room = require('../models/roomModel');
const { v4: uuidv4, validate: uuidValidate } = require('uuid');
const { Op } = require('sequelize');
const RMessage = require('../models/messageModel');

const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET_KEY || 'secret-key';

// ✅ JWT 방식으로 사용자 ID 추출
exports.getRooms = async (req, res) => {
    const u1_id = req.currentUserId;
    if (!u1_id) {
        return res.status(401).json({ message: '로그인이 필요합니다.' });
    }
    const rooms = await Room.findAll({
        where: { u1_id },
        attributes: ['u1_id', 'u2_id', 'r_id', 'r_title', 'r_type']
    });
    res.json({ rooms });
};

// ✅ JWT 기반 addRoom 함수 (중복 방 체크 포함)
exports.addRoom = async (req, res) => {
    const u1_id = req.currentUserId; // JWT에서 추출한 로그인 유저 ID
    const { u2_id, roomName, r_type } = req.body;
    const type = r_type || "general";

    try {
        // ✅ 1. 자기 자신에게 방 생성 요청일 경우
        if (u1_id === u2_id) {
            await exports.initAddRoom({ body: { u1_id, roomName } });
            return res.json({ message: '자기자신 방이 생성되었습니다.' });
        }

        // ✅ 2. 중복 방 존재 여부 확인
        const existingRoom = await Room.findOne({
            where: {
                [Op.or]: [
                    { u1_id, u2_id, r_type: type },
                    { u1_id: u2_id, u2_id: u1_id, r_type: type }
                ]
            }
        });

        if (existingRoom) {
            return res.status(400).json({
                success: false,
                message: '해당 타입의 방이 이미 존재합니다.',
                room: existingRoom
            });
        }

        // ✅ 3. 방 ID(UUID) 생성 및 유효성 확인
        const roomId = uuidv4();
        if (!uuidValidate(roomId)) {
            console.error("생성된 UUID가 유효하지 않습니다.");
            return res.status(500).json({ message: '유효하지 않은 UUID 생성' });
        }

        // ✅ 4. 방 이름 설정
        const r_title = roomName?.trim() || `${u1_id}-${u2_id}`;

        // ✅ 5. 양방향 방 생성
        await Room.create({ u1_id, u2_id, r_id: roomId, r_title, r_type: type });
        await Room.create({ u1_id: u2_id, u2_id: u1_id, r_id: roomId, r_title, r_type: type });

        res.json({ message: '방이 성공적으로 추가되었습니다.' });

    } catch (error) {
        console.error("❌ 방 생성 중 오류:", error);
        res.status(500).json({
            message: `방 추가 중 오류가 발생했습니다.`,
            error: error.message
        });
    }
};

exports.initAddRoom = async (req) => {
    const { u1_id, roomName } = req.body;
    try {
        const roomId = uuidv4();
        const r_title = roomName?.trim() || `${u1_id}의 방`;
        await Room.create({
            u1_id,
            u2_id: u1_id,
            r_id: roomId,
            r_title,
            r_type: 'general',
        });
        return { success: true, message: '방 생성 완료' };
    } catch (error) {
        console.error('방 생성 오류:', error);
        return { success: false, error: '방 생성 실패' };
    }
};

exports.deleteRoom = async (req, res) => {
    const u1_id = req.currentUserId;
    const { u2_id, r_type } = req.params;
    try {
        await Room.destroy({ where: { u1_id, u2_id, r_type } });
        await Room.destroy({ where: { u1_id: u2_id, u2_id: u1_id, r_type } });
        res.json({ message: '방이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: `방 삭제 중 오류: ${error}` });
    }
};

//클라이언트(http)쪽 채팅방 화면만 입장 (실질적 소켓 채팅방입장은 socketServer.js에서 joinRoom으로 함)
exports.enterRoom = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        console.log("💡 Authorization Header:", authHeader);

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ message: '토큰 없음' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, secretKey);
        const u1_id = decoded.userId;

        console.log("✅ JWT 디코딩된 u1_id:", u1_id);

        const { r_id, u2_id } = req.body;

        const room = await Room.findOne({ where: { r_id, u1_id, u2_id } });

        if (!room) {
            return res.status(404).json({ message: '해당 방을 찾을 수 없습니다.' });
        }

        await RMessage.update(
            { is_read: 0 },
            {
                where: {
                    r_id,
                    u2_id: u1_id,
                    is_read: 1
                }
            }
        );

        res.json({ message: '방에 성공적으로 입장했습니다.', room });
    } catch (error) {
        console.error('❌ 방 입장 중 오류:', error);
        res.status(500).json({ message: `방 입장 중 오류: ${error.message}` });
    }
};

exports.updateRoomName = async (req, res) => {
    const u1_id = req.currentUserId;
    const { u2_id, newRoomName, r_type } = req.body;

    try {
        if (!r_type) {
            return res.status(400).json({ message: "방 타입을 입력해야 합니다." });
        }

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