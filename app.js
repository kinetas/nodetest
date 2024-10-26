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
    console.log('���� ����');
  }catch(err){
    console.error('���� ����:', err);
  }
})