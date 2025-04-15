const Room = require('./roomModel');
const Mission = require('./missionModel');

// Room과 Mission 간의 관계 설정
Mission.belongsTo(Room, { foreignKey: 'r_id', as: 'room' });
Room.hasMany(Mission, { foreignKey: 'r_id', as: 'missions' });

module.exports = { Room, Mission };