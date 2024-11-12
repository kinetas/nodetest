const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MRecommand = sequelize.define('MRecommand', {
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
}, {
  tableName: 'm_recommand',
  timestamps: false,
});

module.exports = MRecommand;
