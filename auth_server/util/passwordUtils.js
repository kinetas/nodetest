const bcrypt = require('bcryptjs');

// 비밀번호 암호화 함수
const hashPassword = async (password) => {
    const salt = await bcrypt.genSalt(10); // 솔트 생성
    const hashedPassword = await bcrypt.hash(password, salt);
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