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
    const { u1_id, u2_id } = req.body;
    try {
        await Room.create({ u1_id, u2_id, r_title: `${u1_id}-${u2_id}` });
        res.json({ message: '방이 성공적으로 추가되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: '방 추가 중 오류가 발생했습니다.' });
    }
};

exports.deleteRoom = async (req, res) => {
    const u1_id = req.session.user.id;
    const { u2_id } = req.params;
    try {
        await Room.destroy({ where: { u1_id, u2_id } });
        res.json({ message: '방이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        res.status(500).json({ message: '방 삭제 중 오류가 발생했습니다.' });
    }
};