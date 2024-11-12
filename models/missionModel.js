const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Mission = sequelize.define('Mission', {
  m_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
  u1_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
  u2_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
  m_title: {
    type: DataTypes.STRING(30),
    allowNull: false,
  },
  m_deadline: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  m_reward: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
}, {
  tableName: 'misson', // 실제 테이블 이름에 맞춰 설정합니다.
  timestamps: false,   // createdAt 및 updatedAt 컬럼을 사용하지 않으므로 false로 설정
});

module.exports = Mission;
