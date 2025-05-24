const jwt = require('jsonwebtoken');
const User = require('../models/userModel'); // User 모델 가져오기

const secretKey = process.env.JWT_SECRET_KEY;

// JWT로부터 사용자 ID 추출하는 유틸 함수
const extractUserIdFromToken = (req) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return null;
    try {
      const decoded = jwt.verify(token, secretKey);
      return decoded.userId;
    } catch (err) {
      return null;
    }
  };

  // 로그인한 사용자의 u_id 반환
  exports.getLoggedInUserId = (req, res) => {
    const userId = extractUserIdFromToken(req);  //JWT 기반
    if (!userId) {
      return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
    return res.status(200).json({ userId });
  };
  
  // 로그인한 사용자의 u_nickname 반환
  exports.getLoggedInUserNickname = async (req, res) => {
    const userId = extractUserIdFromToken(req);
    if (!userId) {
      return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
    try {
      const user = await User.findOne({
        where: { u_id: userId },
        attributes: ['u_nickname'],
      });
      if (user) {
        return res.status(200).json({ u_nickname: user.u_nickname });
      } else {
        return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
  };
  
  // 로그인한 사용자의 모든 정보 반환
  exports.getLoggedInUserAll = async (req, res) => {
    const userId = extractUserIdFromToken(req);
    if (!userId) {
      return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
    try {
      const user = await User.findOne({
        where: { u_id: userId },
        attributes: { exclude: ['u_password', 'session_id', 'token'] },
      });
      if (user) {
        // return res.status(200).json(user);
        const userJson = user.toJSON();
        if (user.profile_image) {
          userJson.profile_image = user.profile_image.toString('base64');  // ✅ base64 변환
        }
        return res.status(200).json(userJson);
      } else {
        return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
  };

  exports.chaingeProfileImage = async (req, res) => {
    const userId = extractUserIdFromToken(req);
    if (!userId) {
      return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
  
    if (!req.file) {
      return res.status(400).json({ message: '프로필 이미지가 업로드되지 않았습니다.' });
    }
  
    try {
      await User.update({ profile_image: req.file.buffer }, { where: { u_id: userId } });
      res.status(200).json({ success: true, message: '프로필 이미지가 성공적으로 변경되었습니다.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
  };