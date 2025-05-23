const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CRecom = sequelize.define('CRecom', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    cr_num: {
        type: DataTypes.STRING(40),
        allowNull: false,
    },
    u_id: {
        type: DataTypes.STRING(20),
        allowNull: false,
    },
    recommended: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
}, {
    tableName: 'community_recommendation',
    timestamps: false,
});

module.exports = CRecom;