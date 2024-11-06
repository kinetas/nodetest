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

app.get('/', async function (req, res){
    try{
        await sequelize.authenticate();
        res.send('clear')
      }catch(err){
        res.send('fail', err);
      }
})

//============================================
/*
require('dotenv').config();
const express = require('express');
const { Sequelize, DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

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

// 사용자 모델 정의
const User = sequelize.define('User', {
  username: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
});

// 데이터베이스 동기화
sequelize.sync();

// 테스트용 사용자 추가
async function addTestUser() {
  const hashedPassword = await bcrypt.hash('1234', 10);
  await User.create({
    username: '1111',
    password: hashedPassword
  });
}

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    // 1. ID가 존재하는지 확인
    const user = await User.findOne({ where: { username } });

    if (!user) {
      // 2. ID가 존재하지 않으면 존재하지 않는다는 text 출력
      return res.status(404).json({ message: "사용자 ID가 존재하지 않습니다." });
    }

    // 3. ID가 존재한다면
    // 4. PW가 일치하는지 확인
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      // 5. PW가 일치하지 않으면 일치하지 않는다는 text 출력
      return res.status(401).json({ message: "비밀번호가 일치하지 않습니다." });
    }

    // 6. PW가 일치한다면
    // 7. 로그인 성공 text 출력
    res.json({ message: "로그인 성공" });

  } catch (error) {
    console.error('로그인 에러:', error);
    res.status(500).json({ message: "서버 에러가 발생했습니다." });
  }
});

app.get('/', function (req, res) {
  res.send('Hi World!!');
});

app.listen(3000, async () => {
  try {
    await sequelize.authenticate();
    console.log('데이터베이스 연결 성공');
    await addTestUser();
    console.log('테스트 사용자 추가 완료');
  } catch (err) {
    console.error('데이터베이스 연결 실패:', err);
  }
});*/
