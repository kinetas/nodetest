import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../SessionCookieManager.dart';
import '../../DeviceTokenManager.dart';
import '../Login_page/StartLogin_screen.dart';
import 'SettingWidgets/SettingOptionsList.dart';
import '../../SessionTokenManager.dart';
import '../../DeviceTokenManager.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToMission;
  final VoidCallback onNavigateToCommunity;
  final Function(String newName, ImageProvider newImage)? onProfileEdited;

  const SettingsScreen({
    Key? key,
    required this.onNavigateToHome,
    required this.onNavigateToChat,
    required this.onNavigateToMission,
    required this.onNavigateToCommunity,
    this.onProfileEdited,
  }) : super(key: key);

  /// 로그아웃 로직
  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ 서버에 FCM 토큰 제거 요청


      // ✅ 로그아웃 API 호출
      final response = await SessionCookieManager.post(
        'http://27.113.11.48:3000/auth/api/auth/logoutToken',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("[DEBUG] Logout API Success");
      } else {
        print("[DEBUG] Logout Failed: ${response.statusCode}");
      }

      // ✅ 세션 및 토큰 삭제
      await SessionTokenManager.clearToken();
      await SessionCookieManager.clearSessionCookie();
      DeviceTokenManager().clearToken();

      // ✅ 사용자 피드백 및 라우팅
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃되었습니다.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartLoginScreen()),
            (route) => false,
      );
    } catch (e) {
      print("[ERROR] Logout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          /// 설정 기능 리스트
          SettingOptionsList(
            onProfileEdited: onProfileEdited,
          ),

          const Spacer(),

          /// 로그아웃 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}