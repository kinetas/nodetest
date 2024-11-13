const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('../config/db');
const SECRET_KEY = 'your_secret_key';
const logger = require('../logger');//예외처리

exports.register = (req, res) => {
  const { username, password } = req.body;
  bcrypt.hash(password, 10, (err, hash) => {
    if (err) return res.status(500).send('Error hashing password');
    db.query('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash], (err, result) => {
      if (err) return res.status(500).send('Error registering user');
      res.status(201).send('User registered');
    });
  });
};

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) throw new Error("Username and password are required");

    const user = await db.query('SELECT * FROM users WHERE username = ?', [username]);
    if (user.length === 0) throw new Error("User not found");

    const isMatch = await bcrypt.compare(password, user[0].password);
    if (!isMatch) throw new Error("Invalid password");

    const token = jwt.sign({ id: user[0].id, username: user[0].username }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });
  } catch (error) {
    logger.error(error.message);
    res.status(500).send(error.message);
  }
};
// FCM 토큰 DB에 저장(Flutter에서 FCM 토큰을 생성하고, 이걸 서버로 전송해서 users 테이블에 저장해야됨)
exports.saveToken = (req, res) => {
  const userId = req.user.id;
  const { fcm_token } = req.body;

  db.query('UPDATE users SET fcm_token = ? WHERE id = ?', [fcm_token, userId], (err, result) => {
    if (err) {
      logger.error("Error saving FCM token:", err);
      return res.status(500).send("Error saving FCM token");
    }
    res.send("FCM token saved successfully");
  });
};