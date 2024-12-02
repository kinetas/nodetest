import 'package:flutter/material.dart';

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
            Tab(text: '상대방이 완료한 미션'), // 두 번째 탭
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AssignedMissionsTab(), // 부여한 미션 탭
          CompletedByOthersTab(), // 상대방이 완료한 미션 탭
        ],
      ),
    );
  }
}

class AssignedMissionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '부여한 미션 목록',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class CompletedByOthersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '상대방이 완료한 미션 목록',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}