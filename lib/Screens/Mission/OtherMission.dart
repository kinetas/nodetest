import 'package:flutter/material.dart';
import 'NewMissionScreen/GiveMissionList.dart'; // 부여한 미션 목록
import 'NewMissionScreen/RequestedMissionList.dart'; // 부여한 미션 중 완료된 목록

class OtherMission extends StatefulWidget {
  @override
  _OtherMissionState createState() => _OtherMissionState();
}

class _OtherMissionState extends State<OtherMission> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '부여한 미션',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue, // 선택된 탭의 글자 색상
          unselectedLabelColor: Colors.black54, // 선택되지 않은 탭 글자 색상
          indicatorColor: Colors.blue, // 선택 탭 아래 포인트 색상
          indicatorWeight: 3,
          tabs: const [
            Tab(
              text: '인증 요청이 온 미션',
              icon: Icon(Icons.check_circle_outline),
            ),
            Tab(
              text: '상대방 미션',
              icon: Icon(Icons.list_alt),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RequestedMissionScreen(),
          GiveMissionList(),
        ],
      ),
    );
  }
}