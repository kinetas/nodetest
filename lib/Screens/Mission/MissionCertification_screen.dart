import 'dart:convert';
import 'package:flutter/material.dart';
import '../../SessionCookieManager.dart'; // SessionCookieManager 경로 확인

class MissionCertification {
  /// `m_id` 값을 받아 미션 요청을 서버에 POST로 전송합니다.
  Future<void> sendMissionCertification(String mId, BuildContext context) async {
    final url = Uri.parse('http://54.180.54.31:3000/api/missions/missionRequest');
    final body = jsonEncode({'m_id': mId});

    try {
      // 세션 쿠키를 활용하여 요청 헤더 설정
      final response = await SessionCookieManager.post(
        url.toString(),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // 응답 처리
      if (response.statusCode == 200) {
        print('[SUCCESS] Mission request sent successfully: $mId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mission certified successfully.')),
        );
      } else {
        print('[ERROR] Failed to send mission request. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to certify mission.')),
        );
      }
    } catch (e) {
      print('[ERROR] Error during mission request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while certifying mission.')),
      );
    } finally {
      // 호출된 곳으로 돌아가기
      Navigator.pop(context);
    }
  }
}