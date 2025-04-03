import 'package:flutter/material.dart';
import 'Home/HomeScreen.dart';
import 'Chat/MainChatScreen.dart';
import 'Mission/MissionScreen.dart';
import 'Community/CommunityScreen.dart';
import 'Profile/ProfileScreenMain.dart';
//import 'Setting/settings_screen.dart'; 메인스크린에서 세팅스크린으로 가는길이 없어 주석처리


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(onNavigateToCommunity: () => _onItemTapped(3)), // 커뮤니티로 이동하는 콜백 전달
      ChatScreen(),
      MissionScreen(),
      CommunityScreen(),
      ProfileScreenMain(
        onNavigateToHome: () => _onItemTapped(0),
        onNavigateToChat: () => _onItemTapped(1),
        onNavigateToMission: () => _onItemTapped(2),
        onNavigateToCommunity: () => _onItemTapped(3),
      ),
      /*SettingsScreen(
        onNavigateToHome: () => _onItemTapped(0),
        onNavigateToChat: () => _onItemTapped(1),
        onNavigateToMission: () => _onItemTapped(2),
        onNavigateToCommunity: () => _onItemTapped(3),
      ),*/ //profile로 갈수있게 변경(세팅 스크린 코드는 수정 가능하게 그냥 주석처리)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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