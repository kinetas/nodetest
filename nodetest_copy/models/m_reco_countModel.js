const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const MRecoCount = sequelize.define('MRecoCount', {
  m_title: {
    type: DataTypes.STRING(30),
    primaryKey: true,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  m_count: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: 'm_reco_count',
  timestamps: false,
});

module.exports = MRecoCount;
