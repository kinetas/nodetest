const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const IFriend = sequelize.define('IFriend', {
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
}, {
  tableName: 'i_friend',
  timestamps: false,
});

module.exports = IFriend;
