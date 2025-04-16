const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CWrite = sequelize.define('CWrite', {
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  cw_num: {
    type: DataTypes.STRING(100),
    primaryKey: true,
    allowNull: false,
  },
  cw_title: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  cw_contents: {
    type: DataTypes.STRING(50),
    allowNull: false,
  },
  cw_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'CWrite',
  timestamps: false,
});