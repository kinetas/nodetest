require('dotenv').config();
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
    res.send("?šŒ?›ê°??ž… ?™„ë£?");
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      res.status(400).send("?´ë¯? ì¡´ìž¬?•˜?Š” ID");
    } else {
      res.status(500).send("?„œë²? ?˜¤ë¥?");
    }
  }
});


app.post('/login', async (req, res) => {
  const { id, pw } = req.body;
  try {
    const user = await User.findOne({ where: { id } });
    if (!user) {
      res.status(400).send("ì¡´ìž¬?•˜ì§? ?•Š?Š” ID");
    } else if (user.pw !== pw) {
      res.status(400).send("ë¹„ë??ë²ˆí˜¸ê°? ë¶ˆì¼ì¹?");
    } else {
      res.send("ë¡œê·¸?¸ ?„±ê³?");
    }
  } catch (error) {
    res.status(500).send("?„œë²? ?˜¤ë¥?");
  }
});*/
