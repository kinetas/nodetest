const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const UserPoint = sequelize.define('user_points', {
    user_id: {
        type: DataTypes.STRING(50),
        primaryKey: true,
    },
    points: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
}, {
    tableName: 'user_points',
    timestamps: false
});

module.exports = UserPoint;