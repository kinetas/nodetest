// const { Sequelize, DataTypes } = require('sequelize');
// const sequelize = require('../config/db');

// const Mission = sequelize.define('Mission', {
//   m_id: {
//     type: DataTypes.STRING(40),
//     allowNull: false,
//     unique: true,
//   },
//   u1_id: {
//     type: DataTypes.STRING(20),
//     allowNull: false,
//     primaryKey: true,
//   },
//   u2_id: {
//     type: DataTypes.STRING(20),
//     allowNull: false,
//   },
//   m_title: {
//     type: DataTypes.STRING(30),
//     allowNull: false,
//   },
//   m_deadline: {
//     type: DataTypes.DATE,
//     allowNull: false,
//   },
//   m_reword: {
//     type: DataTypes.STRING(20),
//     allowNull: true,
//   },
//   m_status: {
//     type: DataTypes.STRING(20),
//     allowNull: false,
//   },
//   r_id: {
//     type: DataTypes.STRING(40),
//     allowNull: true, // Room 연결이 선택적인 경우
//   },
//   m_extended: {
//     type: DataTypes.BOOLEAN,
//     defaultValue: false, // 기본값은 false
//   },
//   missionAuthenticationAuthority: {
//     type: DataTypes.STRING(20),
//     allowNull: false,
//     primaryKey: true,
//   },
//   // u1_nickname: {
//   //   type: DataTypes.STRING(30),
//   //   allowNull: false,
//   // },
//   // u2_nickname: {
//   //   type: DataTypes.STRING(30),
//   //   allowNull: false,
//   // },
// }, {
//   tableName: 'misson', // ���� ���̺� �̸��� ���� �����մϴ�.
//   timestamps: false,   // createdAt �� updatedAt �÷��� �������? �����Ƿ� false�� ����
// });

// module.exports = Mission;


//========================m_id만 privatekey로 설정=======================
const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Mission = sequelize.define('Mission', {
  m_id: {
    type: DataTypes.STRING(40),
    allowNull: false,
    primaryKey: true,
  },
  u1_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  u2_id: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  m_title: {
    type: DataTypes.STRING(30),
    allowNull: false,
  },
  m_deadline: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  m_reword: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  m_status: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  r_id: {
    type: DataTypes.STRING(40),
    allowNull: true, // Room 연결이 선택적인 경우
  },
  m_extended: {
    type: DataTypes.BOOLEAN,
    defaultValue: false, // 기본값은 false
  },
  missionAuthenticationAuthority: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  // u1_nickname: {
  //   type: DataTypes.STRING(30),
  //   allowNull: false,
  // },
  // u2_nickname: {
  //   type: DataTypes.STRING(30),
  //   allowNull: false,
  // },
}, {
  tableName: 'misson', // ���� ���̺� �̸��� ���� �����մϴ�.
  timestamps: false,   // createdAt �� updatedAt �÷��� �������? �����Ƿ� false�� ����
});

module.exports = Mission;


