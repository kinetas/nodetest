/*require('dotenv').config();
const express = require('express')
const app = express()
const {Sequelize}=require('sequelize');
//ÃˆÂ¯Â°Ã¦ÂºÂ¯Â¼Ã¶Â·ÃŽ Â°Ã­Ã„Â¥Â°Ã
const sequelize = new Sequelize(
  process.env.DATABASE_NAME,
  process.env.DATABASE_USERNAME,
  process.env.DATABASE_PASSWORD,
  {
    host: process.env.DATABASE_HOST,
    dialect: 'mysql',
    port: 3306
  }
); 

app.get('/', function (req, res) {
  res.send('Hi World!!')
})
app.listen(3000,async () => {
  try{
    await sequelize.authenticate();
    console.log('clear');
  }catch(err){
    console.error('fail', err);
  }
})*/

//============================================
const express = require('express');
const app = express();
const { Sequelize, DataTypes } = require('sequelize');

// Sequelize 초기화
const sequelize = new Sequelize(
  process.env.DATABASE_NAME,
  process.env.DATABASE_USERNAME,
  process.env.DATABASE_PASSWORD,
  {
    host: process.env.DATABASE_HOST,
    dialect: 'mysql',
    port: 3306
  }
);

// User 모델 정의
const User = sequelize.define('User', {
  username: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
});

// 데이터베이스 동기화
sequelize.sync();

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

// '/login' 경로에 대한 GET 요청 처리
app.get('/login', async (req, res) => {
  try {
    // 데이터베이스에서 모든 사용자 정보 조회
    const users = await User.findAll({
      attributes: ['username', 'password']
    });

    // 사용자 정보를 JSON 형태로 응답
    res.json(users);
  } catch (error) {
    console.error('사용자 정보 조회 실패:', error);
    res.status(500).send('서버 오류가 발생했습니다.');
  }
});

app.listen(3000, async () => {
  try {
    await sequelize.authenticate();
    console.log('데이터베이스 연결 성공');
  } catch (err) {
    console.error('데이터베이스 연결 실패:', err);
  }
});
