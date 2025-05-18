const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const MResult = sequelize.define('MResult', {
  m_id: {
    type: DataTypes.STRING(40),
    primaryKey: true,
    allowNull: false,
  },
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  m_status: {
    type: DataTypes.STRING(5),
    allowNull: false,
  },
  m_deadline: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  mission_result_image: {
    type: DataTypes.BLOB('long'),
    allowNull: true,
  },
}, {
  tableName: 'm_result',
  timestamps: false,
});

module.exports = MResult;
//모델 수정필요 =>u2생성