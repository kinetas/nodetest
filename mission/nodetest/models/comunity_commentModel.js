const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

// const CComment = sequelize.define('CComment', {
//   u_id: {
//     type: DataTypes.STRING(20),
//     primaryKey: true,
//     allowNull: false,
//   },
//   cw_num: {
//     type: DataTypes.STRING(100),
//     primaryKey: true,
//     allowNull: false,
//   },
//   cc_num: {
//     type: DataTypes.STRING(30),
//     primaryKey: true,
//     allowNull: false,
//   },
//   cc_comment: {
//     type: DataTypes.STRING(30),
//     allowNull: false,
//   },
//   cw_date: {
//     type: DataTypes.DATE,
//     allowNull: false,
//   },
// }, {
//   tableName: 'CComment',
//   timestamps: false,
// });

const CommunityComment = sequelize.define('CommunityComment', {
  cc_num: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    allowNull: false
  },
  cr_num: {
    type: DataTypes.STRING(40),
    allowNull: false,
    references: {
      model: 'community_room',   //외래 키: community_room.cr_num
      key: 'cr_num'
    },
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  },
  user_nickname: {
    type: DataTypes.STRING(30),
    allowNull: false
  },
  comment: {
    type: DataTypes.STRING(500),
    allowNull: false
  },
  created_time: {
    type: DataTypes.DATE,
    allowNull: true,
    defaultValue: Sequelize.NOW
  },
  u_id: {
    type: DataTypes.STRING(255),
    allowNull: false,
    references: {
      model: 'user',
      key: 'u_id'
    },
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  },
  recommended_num: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
  }
}, {
  tableName: 'community_comments',
  timestamps: false
});

module.exports = CommunityComment;