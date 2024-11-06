/*require('dotenv').config();
const express = require('express')
const app = express()
const {Sequelize}=require('sequelize');
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

/*
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

// User 모델 ?��?�� (?��?�� ?��?���? 구조?�� 맞춤)
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
  tableName: 'user', // ?��?�� ?��?���? ?��름이 'user'?�� 경우
  timestamps: false // createdAt, updatedAt 컬럼?�� ?��?�� 경우
});

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

// ?��?��?�� ?��보�?? �??��?��?�� ?��로운 ?��?��?��
app.get('/users', async function (req, res) {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name'] // password?�� 보안?�� ?��?��
    });
    res.json(users);
  } catch (error) {
    console.error('?��?��?�� ?���? 조회 ?��?��:', error);
    res.status(500).send('?���? ?��류�?? 발생?��?��?��?��.');
  }
});

app.listen(3000, async () => {
  try {
    await sequelize.authenticate();
    console.log('?��?��?��베이?�� ?���? ?���?');
  } catch (err) {
    console.error('?��?��?��베이?�� ?���? ?��?��:', err);
  }
});
*/
