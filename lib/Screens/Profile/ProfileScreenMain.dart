
import 'package:flutter/material.dart';
import 'ProfileWidgets/ProfileHeader.dart';
import 'ProfileWidgets/ProfileCompletedTab.dart';
import 'ProfileWidgets/ProfileInProgressTab.dart';
import '../Setting/settings_screen.dart';

class ProfileScreenMain extends StatefulWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToMission;
  final VoidCallback onNavigateToCommunity;

  const ProfileScreenMain({
    required this.onNavigateToHome,
    required this.onNavigateToChat,
    required this.onNavigateToMission,
    required this.onNavigateToCommunity,
  });

  @override
  State<ProfileScreenMain> createState() => _ProfileScreenMainState();
}

class _ProfileScreenMainState extends State<ProfileScreenMain>
    with SingleTickerProviderStateMixin {
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
    final Color primaryColor = Colors.lightBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onNavigateToHome: widget.onNavigateToHome,
                    onNavigateToChat: widget.onNavigateToChat,
                    onNavigateToMission: widget.onNavigateToMission,
                    onNavigateToCommunity: widget.onNavigateToCommunity,
                    onProfileEdited: (newName, newImage) {
                      // TODO: 프로필 수정 반영 로직 필요 시 작성
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          ProfileHeader(), // ✅ const 제거됨

          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '완료한 미션'),
              Tab(text: '진행중 미션'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProfileCompletedTab(),
                ProfileInProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}