const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

const sequelize = new Sequelize(
  process.env.DATABASE_NAME,
  process.env.DATABASE_USER,
  process.env.DATABASE_PASSWORD,
  {
    host: process.env.DATABASE_HOST,
    dialect: 'mysql',
    port: 3306,
    // timezone: '+09:00', // KST 시간대 설정 추가
    // dialectOptions: {
    //   timezone: 'Asia/Seoul', // MySQL 서버와의 시간대 동기화
    // },
  }
);

module.exports = sequelize;