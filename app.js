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
})
*/
//============================================
require('dotenv').config();
const express = require('express');
const app = express();
const { Sequelize, DataTypes } = require('sequelize');

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

// User 모델 정의 (실제 테이블 구조에 맞춤)
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
  tableName: 'user', // 실제 테이블 이름이 'user'인 경우
  timestamps: false // createdAt, updatedAt 컬럼이 없는 경우
});

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

// 사용자 정보를 가져오는 새로운 라우트
app.get('/users', async function (req, res) {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name'] // password는 보안상 제외
    });
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
