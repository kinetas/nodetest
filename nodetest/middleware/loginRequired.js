const jwt = require('jsonwebtoken');

function loginRequired(req, res, next) {
    // request 헤더로부터 authorization bearer 토큰을 받음.
    const userToken = req.headers["authorization"]?.split(" ")[1];

    // 이 토큰은 jwt 토큰 문자열이거나, 혹은 "null" 문자열이거나, undefined임.
    // 토큰이 "null" 일 경우, login_required 가 필요한 서비스 사용을 제한함.
    if (!userToken || userToken === "null") {
        console.log("서비스 사용 요청이 있습니다. 하지만, Authorization 토큰: 없음");

        return res.status(401).json({
            result: "forbidden-approach",
            message: "로그인한 유저만 사용할 수 있는 서비스입니다.",
        });
    }

    // 해당 token 이 정상적인 token인지 확인
    try {
        const secretKey = process.env.JWT_SECRET_KEY || "secret-key";
        const jwtDecoded = jwt.verify(userToken, secretKey);

        req.currentUserId = jwtDecoded.userId;

        next();
    } catch (error) {
        res.status(401).json({
            result: "forbidden-approach",
            message: "정상적인 토큰이 아닙니다.",
        });

        return;
    }
}

module.exports = loginRequired;