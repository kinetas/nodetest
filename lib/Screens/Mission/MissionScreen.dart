import 'package:flutter/material.dart';
import 'CreateMissionScreen.dart';
import 'AchievementPanel_screen.dart';
import 'MyMission/MyMissionList.dart';
import 'MyMission/MyCompleteMissionList.dart';
import 'OtherMission.dart';

class MissionScreen extends StatefulWidget {
  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 컨트롤러 초기화 (2개의 탭)
  }

  @override
  void dispose() {
    _tabController.dispose(); // 탭 컨트롤러 해제
    super.dispose();
  }

  void _showAchievementPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AchievementPanel(
          onClose: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '미션 목록',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: () {
              // 추천 기능 동작
            },
            child: Text('추천', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white), // 달성률 아이콘
            onPressed: _showAchievementPanel,
            tooltip: '달성률 보기',
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.white), // 비행기 모양 버튼
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherMission(), // OtherMission 화면으로 이동
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MissionCreateScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '내 미션'), // 1번 탭
            Tab(text: '완료한 미션'), // 2번 탭
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            MyMissionList(), // 내 미션 리스트 (1번 탭)
            MyCompleteMissionList(), // 완료한 미션 리스트 (2번 탭)
          ],
        ),
      ),
    );
  }
}