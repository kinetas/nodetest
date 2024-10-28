require('dotenv').config();
const express = require('express')
const app = express()
const {Sequelize}=require('sequelize');
//È¯°æº¯¼ö·Î °íÄ¥°Í
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
  res.send('H! World!!')
})
app.listen(3000,async () => {
  try{
    await sequelize.authenticate();
    console.log('clear');
  }catch(err){
    console.error('fail', err);
  }
})


const User = sequelize.define('User', {
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  id: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  pw: {
    type: DataTypes.STRING,
    allowNull: false
  }
});


app.post('/signup', async (req, res) => {
  const { name, id, pw } = req.body;
  try {
    await User.create({ name, id, pw });
    res.send("회원가입 완료");
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      res.status(400).send("이미 존재하는 ID");
    } else {
      res.status(500).send("서버 오류");
    }
  }
});


app.post('/login', async (req, res) => {
  const { id, pw } = req.body;
  try {
    const user = await User.findOne({ where: { id } });
    if (!user) {
      res.status(400).send("존재하지 않는 ID");
    } else if (user.pw !== pw) {
      res.status(400).send("비밀번호가 불일치");
    } else {
      res.send("로그인 성공");
    }
  } catch (error) {
    res.status(500).send("서버 오류");
  }
});
