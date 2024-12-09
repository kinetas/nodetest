const db = require('../config/db');
const { Op } = require('sequelize');
const NotificationLog = require('../models/notificationModel');
const User = require('../models/userModel');
const admin = require('firebase-admin');
const { getMessaging } = require('firebase-admin/messaging');
/*
//// 클라이언트에서 전달받은 토큰 DB에 저장
const saveToken = async (req, res) => {
    const { userId, token } = req.body;

    // 필수 필드 확인
    if (!userId || !token) {
        return res.status(400).json({ error: 'Missing userId or token' });
    }

    try {
        // 토큰 저장 또는 업데이트
        await db.query(
            'INSERT INTO user_tokens (user_id, token) VALUES (?, ?) ON DUPLICATE KEY UPDATE token = ?',
            [userId, token, token]
        );
        res.status(200).json({ message: 'Token saved successfully' });
    } catch (error) {
        console.error('Error saving token:', error);
        res.status(500).json({ error: 'Failed to save token' });
    }
};
*/
/// 기본 알림 전송 함수
const sendNotification = async (userId, title, body = {}) => {
    try {
        // Sequelize를 사용해 token 조회
        const user = await User.findOne({
            where: { u_id: userId },
            attributes: ['token'],
        });

        if (!user || !user.token) {
            // throw new Error('No token found for user');
            console.error('토큰이 없습니다.');
            return res.status(400).json({ success: false, message: '사용자의 토큰이 존재하지 않습니다.' });
        }

        const token = user.token;

        if (!token) {
            console.error('토큰을 찾을 수 없습니다:', user);
            throw new Error('사용자의 디바이스 토큰이 없습니다.');
        }

        const message = {
            token,
            notification:{
                title,
                body: typeof body === 'string' ? body : JSON.stringify(body),
                },
                };

        // Firebase를 통해 알림 전송
        const response = await getMessaging().send(message);

        // 성공 시 로그 저장
        await NotificationLog.create({
            userId,
            token,
            title,
            body,
            status: 'success',
            timestamp: new Date(),
        });

        console.log(`Notification sent to user ${userId}:`, response);
        return response;
    } catch (error) {
        console.error(`Failed to send notification to user ${userId}:`, error.message);

        // 실패 시 로그 저장
        await NotificationLog.create({
            userId,
            token,
            title,
            body,
            status: 'failed',
            errorMessage: error.message,
            timestamp: new Date(),
        });

        throw error;
    }
};
// API 컨트롤러 함수
const sendNotificationController = async (req, res) => {
    console.log('Request Headers:', req.headers); // 요청 헤더 출력
    console.log('Request Received at Controller:', req.body); // 요청 데이터 확인
    const { userId, token, title, body } = req.body;

    if (!userId || !token || !title || !body) {
        console.error('Missing Required Fields:', req.body); // 누락된 데이터 확인
        return res.status(400).json({ error: 'Missing required fields.' });
    }

    try {
        const response = await sendNotification(userId, token, title, body);
        res.status(200).json({ message: 'Notification sent successfully.', response });
    } catch (error) {
        res.status(500).json({ error: 'Failed to send notification.' });
    }
};
// 친구 요청 알림 함수
const sendFriendRequestNotification = async (senderId, userId) => {
    const title = '친구 요청 알림';
    const body = `${senderId}님이 친구 요청을 보냈습니다.`;
    return await sendNotification(userId, title, body);
};

// 친구 요청 수락 알림 함수
const sendFriendAcceptNotification = async (senderId, userId) => {
    const title = '친구 요청 수락 알림';
    const body = `${senderId}님이 친구 요청을 수락하였습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 생성 알림 함수
const sendMissionCreateNotification = async (senderId, userId) => {
    const title = '미션 생성 알림';
    const body = `${senderId}님이 미션을 생성하였습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 인증 요청 알림 함수
const sendRequestMissionApprovalNotification = async (senderId, userId) => {
    const title = '미션 인증 요청 알림';
    const body = `${senderId}님이 미션 인증을 요청하였습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 성공 알림 함수
const sendMissionSuccessNotification = async (senderId, userId) => {
    const title = '미션 성공 알림';
    const body = `${senderId}님이 미션을 성공 처리하였습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 실패 알림 함수
const sendMissionFailureNotification = async (senderId, userId) => {
    const title = '미션 실패 알림';
    const body = `${senderId}님이 미션을 실패 처리하였습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 마감기한 임박 (10분) 알림 함수
const sendMissionDeadlineTenMinutesNotification = async (userId, missionTitle) => {
    const title = '마감 기한 임박 알림';
    const body = `${missionTitle} 미션의 마감기한이 10분 남았습니다.`;
    return await sendNotification(userId, title, body);
};

// 미션 마감기한 경과 알림 함수
const sendMissionDeadlineNotification = async (userId, missionTitle) => {
    const title = '마감 기한 경과 알림';
    const body = `${missionTitle} 미션의 마감기한이 지났습니다.`;
    return await sendNotification(userId, title, body);
};

// 커뮤니티 미션 수락 알림 함수
const sendAcceptCommunityMissionNotification = async (userId, missionTitle) => {
    const title = '커뮤니티 미션 수락 알림';
    const body = `${missionTitle} 커뮤니티 미션이 수락되어 미션이 생성되었습니다.`;
    return await sendNotification(userId, title, body);
};

// 투표 미션 성공 알림 함수
const sendVoteMissionSuccessNotification = async (userId, missionTitle) => {
    const title = '투표 미션 성공 알림';
    const body = `${missionTitle} 투표 미션이 성공되었습니다.`;
    return await sendNotification(userId, title, body);
};

// 투표 미션 실패 알림 함수
const sendVoteMissionFailureNotification = async (userId, missionTitle) => {
    const title = '투표 미션 실패 알림';
    const body = `${missionTitle} 투표 미션이 실패되었습니다.`;
    return await sendNotification(userId, title, body);
};

//메시지 수신 알림
const sendMessageNotification = async (receiverId, messageContent) => {
    const title = '새로운 메시지 도착';
    const body = `메시지: "${messageContent}"`;

    try {
        return await sendNotification(receiverId, title, body);
    } catch (error) {
        console.error(`Failed to send message notification to user ${receiverId}:`, error.message);
        throw error;
    }
};
module.exports = {
    sendNotificationController,
    sendFriendRequestNotification,
    sendFriendAcceptNotification,
    sendMissionCreateNotification,
    sendMissionSuccessNotification,
    sendMissionFailureNotification,
    sendRequestMissionApprovalNotification,
    sendMissionDeadlineTenMinutesNotification,
    sendMissionDeadlineNotification,
    sendMessageNotification,
    sendAcceptCommunityMissionNotification,
    sendVoteMissionSuccessNotification,
    sendVoteMissionFailureNotification,
};