import 'package:flutter/material.dart';
import 'AddMission_screen.dart';
import 'AchievementPanel_screen.dart';
import 'MyMissionList.dart';
import 'MyCompleteMissionList.dart';
import 'OtherMission.dart';
//a
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

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('미션 목록'),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text('추천', style: TextStyle(color: Colors.black)),
              ),
              IconButton(
                icon: Icon(Icons.send), // 비행기 모양 버튼
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
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMissionScreen(),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '내 미션'), // 1번 탭
                Tab(text: '완료한 미션'), // 2번 탭
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              MyMissionList(), // 내 미션 리스트 (1번 탭)
              MyCompleteMissionList(), // 완료한 미션 리스트 (2번 탭)
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                // missionProvider.toggleAchievementPanel();
              },
              tooltip: '달성률 보기',
            ),
          ),
        ),
        // 달성률 패널 처리
        // if (missionProvider.isAchievementPanelOpen)
        //   GestureDetector(
        //     onTap: missionProvider.toggleAchievementPanel,
        //     child: Container(
        //       color: Colors.black.withOpacity(0.5),
        //     ),
        //   ),
        // if (missionProvider.isAchievementPanelOpen)
        //   Align(
        //     alignment: Alignment.bottomCenter,
        //     child: AchievementPanel(
        //       onClose: missionProvider.toggleAchievementPanel,
        //     ),
        //   ),
      ],
    );
  }
}