
import 'package:flutter/material.dart';
import 'Home/HomeScreen.dart';
import 'Chat/MainChatScreen.dart';
import 'Mission/MissionScreen.dart';
import 'Community/CommunityScreen.dart';
import 'Profile/ProfileScreenMain.dart';
import '../Screens/Login_page/LoginScreen.dart';
import '../SessionTokenManager.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  static late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();

    _widgetOptions = <Widget>[
      HomeScreen(onNavigateToCommunity: () => _onItemTapped(3)),
      ChatScreen(),
      MissionScreen(),
      CommunityScreen(),
      ProfileScreenMain(
        onNavigateToHome: () => _onItemTapped(0),
        onNavigateToChat: () => _onItemTapped(1),
        onNavigateToMission: () => _onItemTapped(2),
        onNavigateToCommunity: () => _onItemTapped(3),
      ),
    ];
  }

  Future<void> _checkAuthentication() async {
    print("🔐 [MainScreen] 로그인 상태 확인 중...");
    final isLoggedIn = await SessionTokenManager.isLoggedIn();
    print("✅ 로그인 여부: $isLoggedIn");

    if (!isLoggedIn) {
      print("⛔ 로그인 안됨 → 로그인 화면으로 이동합니다.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      setState(() {
        _isAuthenticated = true;
        _isCheckingAuth = false;
      });
      print("🎉 인증 완료 → 메인화면 렌더링");
    }
  }

  void _onItemTapped(int index) {
    print("📱 탭 선택됨: $index");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return SizedBox.shrink();
    }

    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: '미션'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
