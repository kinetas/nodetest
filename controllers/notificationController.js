const { sendNotification } = require('../config/FCM');

// Express 요청을 처리하고 sendNotification 호출(클라이언트로부터 필수값 검증)
const sendNotificationController = async (req, res) => {
    const {token, title, body } = req.body;


    if (!token || !title || !body) {
        return res.status(400).json({ message: 'FCM 토큰, 제목, 내용이 필요합니다.' });
        console.log('Request received:', req.body);
    }

    try {
        const response = await sendNotification(title, body);
        res.status(200).json({ message: 'Notification sent successfully', response });
    } catch (error) {
        res.status(500).json({ message: 'Failed to send notification', error });
    }
};

module.exports = { sendNotificationController };