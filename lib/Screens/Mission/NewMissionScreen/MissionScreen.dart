import 'package:flutter/material.dart';
import 'package:capstone_1_project/Screens/Mission/NewMissionScreen/CreateMissionScreen.dart';
import 'package:capstone_1_project/Screens/Mission/NewMissionScreen/SelectCreateMission.dart';
import 'AchievementPanel_screen.dart';
import 'MyMissionList.dart';
import 'MyCompleteMissionList.dart';
import '../OtherMission.dart';
import '../ChatBotAI/AIChatConversationScreen.dart';
import 'MissionHome.dart';

class MissionScreen extends StatefulWidget {
  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAchievementPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AchievementPanel(onClose: () => Navigator.pop(context)),
    );
  }

  void _openAIMissionFlow() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AIChatConversationScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionCreateScreen(
            initialTitle: result['title'],
            initialMessage: result['message'],
            initialCategory: result['category'],
            aiSource: result['source'],
            isAIMission: true,
          ),
        ),
      );
      _openAIMissionFlow();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.lightBlue;
    const Color backgroundColor = Colors.white;
    const Color textColor = Colors.black87;

    final double bodyHeight = MediaQuery.of(context).size.height - kToolbarHeight - 100;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          '미션',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: textColor),
            onPressed: _showAchievementPanel,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: textColor),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OtherMission()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: textColor),
            tooltip: '미션 직접 생성',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SelectCreateMission()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: '미션 홈'),
            Tab(text: '진행 중 미션'),
            Tab(text: '완료한 미션'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(height: bodyHeight, child: MissionHome()),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(height: bodyHeight, child: MyMissionList()),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(height: bodyHeight, child: MyCompleteMissionList()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'AI 추천 미션 생성',
        onPressed: _openAIMissionFlow,
        child: const Icon(Icons.smart_toy),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}