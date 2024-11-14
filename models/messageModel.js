const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const RMessage = sequelize.define('RMessage', {
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
    message_num: {
      type: DataTypes.STRING(20),
      primaryKey: true,
      allowNull: false,
    },
    send_date: {
      type: DataTypes.DATETIME,
      allowNull: false,
    },
    message_contents: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
  }, {
    tableName: 'r_message',
    timestamps: false,
  });
  
  module.exports = RMessage;