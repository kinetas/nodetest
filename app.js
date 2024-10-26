const express = require('express')
const app = express()
const {Sequelize}=require('sequelize');

const sequelize = new Sequelize(
  process.env.DATABASE_NAME,
  process.env.DATABASE_USERNAME,
  process.env.DATABASE_PASSWORD,
  {
    host: process.env.DATABASE_HOST,
    dialect: 'mysql'
  }
);

app.get('/', function (req, res) {
  res.send('Hey World!!')
})

app.listen(3000,async () => {
  try{
    await sequelize.authenticate();
    console.log('연결 성공');
  }catch(err){
    console.error('연결 실패:', err);
  }
})