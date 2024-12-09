import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login_page/StartLogin_screen.dart'; // StartLogin_screen.dart 경로 확인
import '../../SessionCookieManager.dart'; // SessionCookieManager 경로 확인
import '../../DeviceTokenManager.dart'; // DeviceTokenManager 경로 확인

class SettingsScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _logout(context); // 로그아웃 호출
          },
          child: Text('로그아웃'),
        ),
      ),
    );
  }
}