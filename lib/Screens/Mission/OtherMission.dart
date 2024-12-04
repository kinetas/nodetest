import 'package:flutter/material.dart';
import 'GiveMissionList.dart'; // 부여한 미션 목록
import 'GiveCompleteMissionList.dart'; // 부여한 미션 중 완료된 목록

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
        title: Text('Other Mission'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '부여한 미션'), // 첫 번째 탭
            Tab(text: '부여한 미션 중 완료'), // 두 번째 탭
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GiveMissionList(), // 부여한 미션 탭 연결
          GiveCompleteMissionList(), // 부여한 미션 중 완료된 탭 연결
        ],
      ),
    );
  }
}