import 'package:flutter/material.dart';
import 'GiveMissionList.dart'; // 부여한 미션 목록
import 'RequestedMissionList.dart'; // 부여한 미션 중 완료된 목록

class OtherMission extends StatefulWidget {
  @override
  _OtherMissionState createState() => _OtherMissionState();
}

class _OtherMissionState extends State<OtherMission> with SingleTickerProviderStateMixin {
  late TabController _tabController; // TabController 초기화

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2개의 탭
  }

  @override
  void dispose() {
    _tabController.dispose(); // TabController 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '부여한 미션',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: '부여한 미션',
              icon: Icon(Icons.list_alt), // 첫 번째 탭 아이콘
            ),
            Tab(
              text: '완료된 미션',
              icon: Icon(Icons.check_circle_outline), // 두 번째 탭 아이콘
            ),
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
            GiveMissionList(), // 부여한 미션 탭 연결
            RequestedMissionScreen(), // 부여한 미션 중 완료된 탭 연결
          ],
        ),
      ),
    );
  }
}