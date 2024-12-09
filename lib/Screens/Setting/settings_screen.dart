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
      await prefs.clear();

      // 세션 쿠키 삭제
      await SessionCookieManager.clearSessionCookie();
      print("[DEBUG] Session cookie cleared during logout.");

      // 디바이스 토큰 삭제
      DeviceTokenManager().clearToken();
      print("[DEBUG] Device token cleared during logout.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃되었습니다.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StartLoginScreen()),
            (route) => false,
      );
    } catch (e) {
      print("[ERROR] Logout process failed: $e");

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
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildCustomButton('홈 화면으로 이동', onNavigateToHome),
            SizedBox(height: 10),
            _buildCustomButton('채팅 화면으로 이동', onNavigateToChat),
            SizedBox(height: 10),
            _buildCustomButton('미션 화면으로 이동', onNavigateToMission),
            SizedBox(height: 10),
            _buildCustomButton('커뮤니티 화면으로 이동', onNavigateToCommunity),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                '로그아웃',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightBlue,
        shadowColor: Colors.lightBlueAccent,
        elevation: 3,
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}