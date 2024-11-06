const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('user', {
    u_id: {
        type: DataTypes.STRING,
        primaryKey: true,
        autoIncrement: true
    },
    u_password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    u_nickname: {
        type: DataTypes.STRING,
        allowNull: false
    },
    u_name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    u_birth: {
        type: DataTypes.DATE,
        allowNull: true
    },
    u_location: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    tableName: 'user',
    timestamps: false
});

module.exports = User;