const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

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
    primaryKey: true,
  },
  r_id: {
    type: DataTypes.STRING(40),
    primaryKey: true,
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

module.exports = Mission;
