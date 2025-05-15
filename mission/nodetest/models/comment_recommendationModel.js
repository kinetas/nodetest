const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CmtRecom = sequelize.define('CmtRecom', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    cc_num: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    u_id: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    recommended: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
}, {
    tableName: 'comment_recommendation',
    timestamps: false,
    indexes: [
        {
            unique: true,
            fields: ['cc_num', 'u_id']  // 한 유저가 한 댓글에 한 번만 추천
        }
    ]
});

module.exports = CmtRecom;