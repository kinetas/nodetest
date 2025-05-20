const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CRoom = sequelize.define('CRoom', {
    u_id: {
        type: DataTypes.STRING(20),
        allowNull: false,
        primaryKey: true,
    },
    cr_num: {
        type: DataTypes.STRING(40),
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
    contents: {
        type: DataTypes.STRING(500),
        allowNull: true,
    },
    deadline: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    category: {
        type: DataTypes.STRING(20),
        allowNull: true,
    },
    community_type: {
        type: DataTypes.ENUM('mission', 'general'),
        allowNull: false,
        defaultValue: 'mission',
    },
    hits: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    },
    recommended_num: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    },
    maded_time: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    image: {
        type: DataTypes.BLOB('long'),
        allowNull: true,
    },
    // ✅ 인기글 여부 (10분 내 추천수 5 이상 또는 추천수 30 이상)
    popularity: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
}, {
    tableName: 'community_room', // 테이블 이름 (DB 테이블 이름과 매칭)
    timestamps: false, // createdAt, updatedAt 컬럼 사용 안 함
});

module.exports = CRoom;