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

// User Î™®Îç∏ ?†ï?ùò (?ã§?†ú ?Öå?ù¥Î∏? Íµ¨Ï°∞?óê ÎßûÏ∂§)
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
  tableName: 'user', // ?ã§?†ú ?Öå?ù¥Î∏? ?ù¥Î¶ÑÏù¥ 'user'?ù∏ Í≤ΩÏö∞
  timestamps: false // createdAt, updatedAt Ïª¨Îüº?ù¥ ?óÜ?äî Í≤ΩÏö∞
});

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

// ?Ç¨?ö©?ûê ?†ïÎ≥¥Î?? Í∞??†∏?ò§?äî ?ÉàÎ°úÏö¥ ?ùº?ö∞?ä∏
app.get('/users', async function (req, res) {
  try {
    const users = await User.findAll({
      attributes: ['id', 'name'] // password?äî Î≥¥Ïïà?ÉÅ ?†ú?ô∏
    });
    res.json(users);
  } catch (error) {
    console.error('?Ç¨?ö©?ûê ?†ïÎ≥? Ï°∞Ìöå ?ã§?å®:', error);
    res.status(500).send('?ÑúÎ≤? ?ò§Î•òÍ?? Î∞úÏÉù?ñà?äµ?ãà?ã§.');
  }
});

app.listen(3000, async () => {
  try {
    await sequelize.authenticate();
    console.log('?ç∞?ù¥?Ñ∞Î≤†Ïù¥?ä§ ?ó∞Í≤? ?Ñ±Í≥?');
  } catch (err) {
    console.error('?ç∞?ù¥?Ñ∞Î≤†Ïù¥?ä§ ?ó∞Í≤? ?ã§?å®:', err);
  }
});
*/
