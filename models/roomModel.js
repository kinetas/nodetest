const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Mission = require('../models/missionModel');

const Room = sequelize.define('Room', {
  u1_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  u2_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  r_id: {
    type: DataTypes.STRING(40),
    primaryKey: true,
    allowNull: false,
  },
  r_title: {
    type: DataTypes.STRING(30),
    allowNull: false,
  },
  r_type: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
}, {
  tableName: 'room',
  timestamps: false,
});

Room.hasMany(Mission, { foreignKey: 'r_id', as: 'misson' });

module.exports = Room;
