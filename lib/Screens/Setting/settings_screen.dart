import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login_page/StartLogin_screen.dart'; // StartLogin_screen.dart 경로 확인
import '../../SessionCookieManager.dart'; // SessionCookieManager 경로 확인
import '../../DeviceTokenManager.dart'; // DeviceTokenManager 경로 확인

class SettingsScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToMission;
  final VoidCallback onNavigateToCommunity;

  SettingsScreen({
    required this.onNavigateToHome,
    required this.onNavigateToChat,
    required this.onNavigateToMission,
    required this.onNavigateToCommunity,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      // 로그아웃 API 호출
      final response = await SessionCookieManager.post(
        'http://54.180.54.31:3000/api/auth/logout',
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("[DEBUG] Logout API called successfully.");
      } else {
        print("[DEBUG] Logout API failed with status: ${response.statusCode}");
      }

      // 모든 SharedPreferences 데이터 삭제
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 모든 저장된 데이터 삭제 (자동 로그인 정보 포함)

      // 세션 쿠키 삭제
      await SessionCookieManager.clearSessionCookie();
      print("[DEBUG] Session cookie cleared during logout.");

      // 디바이스 토큰 삭제
      DeviceTokenManager().clearToken();
      print("[DEBUG] Device token cleared during logout.");

      // 알림 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃되었습니다.')),
      );

      // StartLoginScreen으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StartLoginScreen()),
            (route) => false, // 이전 화면 스택 제거
      );
    } catch (e) {
      print("[ERROR] Logout process failed: $e");

      // 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: onNavigateToHome,
            child: Text('홈 화면으로 이동'),
          ),
          ElevatedButton(
            onPressed: onNavigateToChat,
            child: Text('채팅 화면으로 이동'),
          ),
          ElevatedButton(
            onPressed: onNavigateToMission,
            child: Text('미션 화면으로 이동'),
          ),
          ElevatedButton(
            onPressed: onNavigateToCommunity,
            child: Text('커뮤니티 화면으로 이동'),
          ),
          ElevatedButton(
            onPressed: () => _logout(context),
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}