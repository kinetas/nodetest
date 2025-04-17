const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CComment = sequelize.define('CComment', {
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
  cc_num: {
    type: DataTypes.STRING(30),
    primaryKey: true,
    allowNull: false,
  },
  cc_comment: {
    type: DataTypes.STRING(30),
    allowNull: false,
  },
  cw_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'CComment',
  timestamps: false,
});