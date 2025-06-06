const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const CVote = sequelize.define('CVote', {
  u_id: {
    type: DataTypes.STRING(20),
    primaryKey: true,
    allowNull: false,
  },
  c_number: {
    type: DataTypes.STRING(100),
    primaryKey: true,
    allowNull: false,
  },
  c_title: {
    type: DataTypes.STRING(40),
    allowNull: false,
  },
  c_contents: {
    type: DataTypes.STRING(50),
    allowNull: true,
  },
  c_good: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  c_bad: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  c_deletedate: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  // c_image: {
  //   type: DataTypes.BLOB('long'), // 이미지 데이터를 BLOB으로 저장
  //   allowNull: true,
  // },
  c_image: {
      type: DataTypes.STRING(255), // 이미지 데이터를 BLOB으로 저장
      allowNull: true,
    },
}, {
  tableName: 'comunity_vote',
  timestamps: false,
  hooks: {
    beforeUpdate: (vote, options) => {
      const currentDate = new Date();
      if (currentDate >= vote.c_deletedate) {
        throw new Error("수정할 수 없는 투표입니다. 투표가 이미 종료되었습니다.");
      }
    }
  }
});

module.exports = CVote;
