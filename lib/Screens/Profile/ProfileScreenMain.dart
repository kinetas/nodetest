import 'package:flutter/material.dart';
import '../Setting/settings_screen.dart';
import 'ProfileWidgets/ProfileHeader.dart'; // 프로필 아이콘(헤더) 위젯
import 'ProfileWidgets/ProfileCompletedTab.dart';
import 'ProfileWidgets/ProfileInProgressTab.dart';

class ProfileScreenMain extends StatefulWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToMission;
  final VoidCallback onNavigateToCommunity;

  const ProfileScreenMain({
    Key? key,
    required this.onNavigateToHome,
    required this.onNavigateToChat,
    required this.onNavigateToMission,
    required this.onNavigateToCommunity,
  }) : super(key: key);

  @override
  State<ProfileScreenMain> createState() => _ProfileScreenMainState();
}

class _ProfileScreenMainState extends State<ProfileScreenMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ 현재 사용자 이름과 프로필 이미지 상태
  String _userName = '사용자 이름';
  ImageProvider _profileImage = const AssetImage('assets/default_profile.png');

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

  /// ✅ SettingsScreen → SettingOptionsList → ProfileEditScreen
  /// 에서 수정된 사용자 정보를 콜백으로 받아와 상태 업데이트
  void _handleProfileUpdated(String name, ImageProvider image) {
    setState(() {
      _userName = name;
      _profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('내 프로필'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                    onProfileEdited: _handleProfileUpdated, // ✅ 콜백 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// ✅ 사용자 정보 전달
          ProfileHeader(
            userName: _userName,
            profileImage: _profileImage,
          ),

          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: '완료된 미션'),
                Tab(text: '진행중 미션'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
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
