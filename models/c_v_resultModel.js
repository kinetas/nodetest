const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CV_result = sequelize.define('CV_result', {
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  c_number: {
    type: DataTypes.STRING(100),
    primaryKey: true,
    allowNull: false,
  },
  c_title: {
    type: DataTypes.STRING(10),
    allowNull: false,
  },
  c_contents: {
    type: DataTypes.STRING(50),
    allowNull: false,
  },
  c_good: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  c_bad: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  c_deletedate: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'c_v_result',
  timestamps: false,
});

module.exports = CV_result;
