
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MissionProvider.dart';
import 'AddMission_screen.dart';
import 'AchievementPanel_screen.dart';
import 'mission_list.dart';

class MissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);

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
          ),
          body: missionProvider.missions.isEmpty
              ? Center(child: Text('미션 없음'))
              : MissionList(missions: missionProvider.missions),
          bottomNavigationBar: BottomAppBar(
            child: IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                missionProvider.toggleAchievementPanel();
              },
              tooltip: '달성률 보기',
            ),
          ),
        ),
        if (missionProvider.isAchievementPanelOpen)
          GestureDetector(
            onTap: missionProvider.toggleAchievementPanel,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        if (missionProvider.isAchievementPanelOpen)
          Align(
            alignment: Alignment.bottomCenter,
            child: AchievementPanel(
              onClose: missionProvider.toggleAchievementPanel,
            ),
          ),
      ],
    );
  }
}
