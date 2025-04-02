import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../SessionCookieManager.dart';
import '../../DeviceTokenManager.dart';
import '../Login_page/StartLogin_screen.dart';
import 'SettingWidgets/SettingOptionsList.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToMission;
  final VoidCallback onNavigateToCommunity;

  const SettingsScreen({
    Key? key,
    required this.onNavigateToHome,
    required this.onNavigateToChat,
    required this.onNavigateToMission,
    required this.onNavigateToCommunity,
  }) : super(key: key);

  // 로그아웃 처리 함수
  Future<void> _logout(BuildContext context) async {
    try {
      final response = await SessionCookieManager.post(
        'http://27.113.11.48:3000/api/auth/logout',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("[DEBUG] Logout API Success");
      } else {
        print("[DEBUG] Logout Failed: ${response.statusCode}");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await SessionCookieManager.clearSessionCookie();
      DeviceTokenManager().clearToken();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃되었습니다.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => StartLoginScreen()),
            (route) => false,
      );
    } catch (e) {
      print("[ERROR] Logout Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 고정
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

          // ✅ 상단 네 가지 주요 이동 버튼 (2x2 레이아웃 + 터치 피드백)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildTopButton(context, '홈 이동', onNavigateToHome),
                _buildTopButton(context, '채팅 이동', onNavigateToChat),
                _buildTopButton(context, '미션 이동', onNavigateToMission),
                _buildTopButton(context, '커뮤니티 이동', onNavigateToCommunity),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Divider(thickness: 1, height: 16),

          // ✅ 중단 기능 버튼 목록 (모듈화)
          const SettingOptionsList(),

          const Spacer(),

          // ✅ 하단 로그아웃 버튼
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
                minimumSize: Size(double.infinity, 50),
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

  /// ✅ 상단 주요 버튼 하나 생성 (InkWell로 터치 피드백 적용)
  Widget _buildTopButton(
      BuildContext context,
      String label,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.blue.withOpacity(0.2),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
