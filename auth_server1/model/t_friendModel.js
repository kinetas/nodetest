const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const TFriend = sequelize.define('TFriend', {
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  f_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  f_create: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  f_status: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: 't_friend',
  timestamps: false,
});

module.exports = TFriend;
