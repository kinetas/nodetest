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

//============================================
const { DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');

const User = sequelize.define('User', {
  username: {
    type: DataTypes.STRING,
    allowNull: false
  },
  userId: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
});


sequelize.sync();


async function signup(username, userId, password) {
  try {
    
    const existingUser = await User.findOne({ where: { userId } });
    if (existingUser) {
      return { success: false, message: 'ex id' };
    }

    
    const hashedPassword = await bcrypt.hash(password, 10);

    
    await User.create({ username, userId, password: hashedPassword });
    return { success: true, message: 'Signup Success' };
  } catch (error) {
    console.error('Signup Error:', error);
    return { success: false, message: 'Error' };
  }
}


async function login(userId, password) {
  try {
    
    const user = await User.findOne({ where: { userId } });
    if (!user) {
      return { success: false, message: 'No User' };
    }

    
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return { success: false, message: 'PW' };
    }

    return { success: true, message: 'Login Success', user: { id: user.id, username: user.username, userId: user.userId } };
  } catch (error) {
    console.error('Login Error:', error);
    return { success: false, message: '로그인 중 오류가 발생했습니다.' };
  }
}


app.post('/signup', async (req, res) => {
  const { username, userId, password } = req.body;
  const result = await signup(username, userId, password);
  res.json(result);
});

app.post('/login', async (req, res) => {
  const { userId, password } = req.body;
  const result = await login(userId, password);
  res.json(result);
});
