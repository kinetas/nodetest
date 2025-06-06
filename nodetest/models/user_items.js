const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const UserItems = sequelize.define('user_items', {
    user_id: {
        type: DataTypes.STRING,
        primaryKey: true,
    },
    item_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
    },
    purchased_at: {
        type: DataTypes.DATE,
        allowNull: true
    },
}, {
    tableName: 'user_items',
    timestamps: false
});

module.exports = UserItems;