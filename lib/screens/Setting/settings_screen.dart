import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login_page/StartLogin_screen.dart'; // StartLogin_screen.dart 경로 확인

class SettingsScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 저장된 데이터 삭제 (자동 로그인 정보 포함)

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