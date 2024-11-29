const Sequelize = require('sequelize');
const db = require('../config/db');

const NotificationLog = db.define('NotificationLog', {
    userId: {
        type: Sequelize.STRING,
        allowNull: false,
        },
    title: {
        type: Sequelize.STRING,
        allowNull: false,
        },
    body: {
        type: Sequelize.STRING,
        allowNull: false,
        },
    status: {
        type: Sequelize.STRING,
        allowNull: false, // 'success' 또는 'failed'
        },
    errorMessage: {
        type: Sequelize.STRING,
        allowNull: true,
        },
    readStatus: { // 읽음 상태 추가
        type: Sequelize.BOOLEAN,
        defaultValue: false,
        },
    timestamp: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
        },
});

module.exports = NotificationLog;