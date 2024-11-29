const Room = require('./roomModel');
const Mission = require('./missionModel');

// Room과 Mission 간의 관계 설정
Room.hasMany(Mission, { foreignKey: 'r_id', as: 'missions' });
Mission.belongsTo(Room, { foreignKey: 'r_id', as: 'room' });

module.exports = { Room, Mission };