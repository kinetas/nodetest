// controllers/roomController.js
const Room = require('../models/roomModel');

exports.getRooms = async (req, res) => {
    const userId = req.session.user.id;
    const rooms = await Room.findAll({
        where: { u1_id: userId }
    });
    res.json({ rooms });
};

exports.addRoom = async (req, res) => {
    // const u1_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
    // const { u2_id } = req.body;

    const { u2_id } = req.body;
    // let u1_id;

    // 세션에 저장된 사용자 ID가 있으면 u1_id에 할당, 없으면 u2_id와 동일하게 설정
    if (req.session && req.session.user && req.session.user.id) {
        const u1_id = req.session.user.id; // 세션에서 사용자 ID 가져오기
        try {
            await Room.create({ u1_id, u2_id, r_title: `${u1_id}-${u2_id}` });
            await Room.create({ u1_id: u2_id, u2_id:u1_id, r_title: `${u2_id}-${u1_id}` });
            res.json({ message: '방이 성공적으로 추가되었습니다.' });
        } catch (error) {
            console.error(error); // 추가로 오류 로깅
            res.status(500).json({ message: '방 추가 중 오류가 발생했습니다.' });
        }
    } else {
        try {
            await Room.create({ u2_id, r_title: `${u2_id}` });
            res.json({ message: '방이 성공적으로 추가되었습니다.' });
        } catch (error) {
            console.error(error); // 추가로 오류 로깅
            res.status(500).json({ message: '방 추가 중 오류가 발생했습니다.' });
        }
    }

    // try {
    //     await Room.create({ u1_id, u2_id, r_title: `${u1_id}-${u2_id}` });
    //     await Room.create({ u1_id: u2_id, u2_id:u1_id, r_title: `${u2_id}-${u1_id}` });
    //     res.json({ message: '방이 성공적으로 추가되었습니다.' });
    // } catch (error) {
    //     console.error(error); // 추가로 오류 로깅
    //     res.status(500).json({ message: '방 추가 중 오류가 발생했습니다.' });
    // }
};

exports.deleteRoom = async (req, res) => {
    const u1_id = req.session.user.id;
    const { u2_id } = req.params;
    try {
        await Room.destroy({ where: { u1_id, u2_id } });
        await Room.destroy({ where: { u1_id:u2_id, u2_id:u1_id } });
        res.json({ message: '방이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: '방 삭제 중 오류가 발생했습니다.' });
    }
};