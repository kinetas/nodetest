const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const c_v_notdup = sequelize.define('c_v_notdup', {
  u_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
  c_number: {
    type: DataTypes.STRING(100),
    allowNull: false,
    primaryKey: true,
  },
  vote_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
    primaryKey: true,
  },
}, {
  tableName: 'c_v_notdup', // 실제 테이블 이름
  timestamps: false, // createdAt, updatedAt 필드 사용 안 함
});

module.exports = c_v_notdup;