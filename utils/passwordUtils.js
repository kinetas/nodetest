const bcrypt = require('bcryptjs');

// 비밀번호 암호화 함수
const hashPassword = async (password) => {
    const saltRounds = 10; // 솔트 라운드 수
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
};

// 비밀번호 확인 함수
const comparePassword = async (password, hashedPassword) => {
    const isMatch = await bcrypt.compare(password, hashedPassword);
    return isMatch;
};

module.exports = {
    hashPassword,
    comparePassword,
};