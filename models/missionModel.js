const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const Room = require('../models/roomModel');
const CRoom = require('../models/comunity_roomModel');

const Mission = sequelize.define('Mission', {
  m_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    unique: true,
  },
  u1_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
  u2_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  m_title: {
    type: DataTypes.STRING(30),
    allowNull: false,
  },
  m_deadline: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  m_reword: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  m_status: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
}, {
  tableName: 'misson', // ���� ���̺� �̸��� ���� �����մϴ�.
  timestamps: false,   // createdAt �� updatedAt �÷��� �������? �����Ƿ� false�� ����
});


// Room 관계
Mission.belongsTo(Room, { foreignKey: 'r_id', as: 'room' });

// Community Room 관계
Mission.belongsTo(CRoom, { foreignKey: 'cr_num', as: 'communityRoom' });

module.exports = Mission;
