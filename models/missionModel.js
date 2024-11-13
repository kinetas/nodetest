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
  m_reword: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
}, {
  tableName: 'misson', // ���� ���̺� �̸��� ���� �����մϴ�.
  timestamps: false,   // createdAt �� updatedAt �÷��� ������� �����Ƿ� false�� ����
});

module.exports = Mission;
