const { Sequelize, DataTypes, TINYINT } = require('sequelize');
const sequelize = require('../config/db');
const RMessage = sequelize.define('RMessage', {
  //   u1_id: {
  //     type: DataTypes.STRING(20),
  //     primaryKey: true,
  //     allowNull: false,
  //   },
  //   u2_id: {
  //     type: DataTypes.STRING(20),
  //     primaryKey: true,
  //     allowNull: false,
  //   },
  //   r_id: {
  //     type: DataTypes.STRING(40),
  //     primaryKey: true,
  //     allowNull: false,
  //   },
  //   message_num: {
  //     type: DataTypes.STRING(20),
  //     primaryKey: true,
  //     allowNull: false,
  //   },
  //   send_date: {
  //     type: DataTypes.DATE,
  //     allowNull: false,
  //   },
  //   message_contents: {
  //       type: DataTypes.STRING(100),
  //       allowNull: false,
  //     },
  // }, {
  //   tableName: 'r_message',
  //   timestamps: false,
  // });
  u1_id: {
    type: DataTypes.STRING(20),
    primaryKey: false,
    allowNull: true,
  },
  u2_id: {
    type: DataTypes.STRING(20),
    primaryKey: false,
    allowNull: true,
  },
  r_id: {
    type: DataTypes.STRING(40),
    primaryKey: true,
    allowNull: false,
  },
  message_num: {
    type: DataTypes.STRING(20),
    primaryKey: false,
    allowNull: true,
  },
  send_date: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  message_contents: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  image: {
    type: DataTypes.BLOB('long'),
    allowNull: true,
  }, // 변경된 부분 - 이미지 필드 추가
  image_type: {
    type: DataTypes.STRING(50),
    allowNull: true,
  }, // 변경된 부분 - 이미지 타입 필드 추가
  is_read: {
    type: TINYINT(1),
    allowNull: true,
  }
}, {
  tableName: 'r_message',
  timestamps: false,
});
  
  module.exports = RMessage;