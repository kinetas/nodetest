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


/*const User = sequelize.define('User', {
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
    res.send("?��?���??�� ?���?");
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      res.status(400).send("?���? 존재?��?�� ID");
    } else {
      res.status(500).send("?���? ?���?");
    }
  }
});


app.post('/login', async (req, res) => {
  const { id, pw } = req.body;
  try {
    const user = await User.findOne({ where: { id } });
    if (!user) {
      res.status(400).send("존재?���? ?��?�� ID");
    } else if (user.pw !== pw) {
      res.status(400).send("비�??번호�? 불일�?");
    } else {
      res.send("로그?�� ?���?");
    }
  } catch (error) {
    res.status(500).send("?���? ?���?");
  }
});*/
