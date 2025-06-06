const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const UserLeagueStatus = sequelize.define('user_league_status', {
    user_id: {
        type: DataTypes.STRING(50),
        primaryKey: true,
    },
    league_id: {
        type: DataTypes.STRING(50),
        allowNull: false
    },
    lp: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    updated_at: {
        type: DataTypes.DATE,
        allowNull: true
    },
}, {
    tableName: 'user_league_status',
    timestamps: false
});

module.exports = UserLeagueStatus;