const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CRoom = sequelize.define('CRoom', {
    u_id: {
        type: DataTypes.STRING(20),
        allowNull: false,
        primaryKey: true,
    },
    cr_num: {
        type: DataTypes.STRING(20),
        allowNull: false,
        primaryKey: true,
    },
    cr_title: {
        type: DataTypes.STRING(20),
        allowNull: true,
    },
    cr_status: {
        type: DataTypes.STRING(5),
        allowNull: true,
    },
    u2_id: {
        type: DataTypes.STRING(20),
        allowNull: true,
    },
    m1_status: {
        type: DataTypes.STRING(5),
        allowNull: true,
    },
    m2_status: {
        type: DataTypes.STRING(5),
        allowNull: true,
    },
}, {
    tableName: 'community_room', // 테이블 이름 (DB 테이블 이름과 매칭)
    timestamps: false, // createdAt, updatedAt 컬럼 사용 안 함
});

module.exports = CRoom;