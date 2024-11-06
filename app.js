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
})*/

/*
//============================================
require('dotenv').config();
const express = require('express');
const { Sequelize, DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const bodyParser = require('body-parser');

const app = express();


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

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
    return { success: false, message: 'Login Error' };
  }
}

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

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

sequelize.sync().then(() => {
  app.listen(3000, '0.0.0.0', async () => {
    try {
      await sequelize.authenticate();
      console.log('Database connection has been established successfully.');
      console.log('Server is running on port 3000');
    } catch (err) {
      console.error('Unable to connect to the database:', err);
    }
  });
});
*/
const express = require('express');
const dotenv = require('dotenv');
const sequelize = require('./config/db');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

const app = express();
app.use(express.json());

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 3000;

// 데이터베이스 연결 확인
sequelize.authenticate()
    .then(() => {
        console.log('Database connected...');
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });
    

