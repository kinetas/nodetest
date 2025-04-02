import 'package:flutter/material.dart';
import '../Setting/settings_screen.dart';
import 'ProfileWidgets/ProfileHeader.dart'; // 프로필아이콘(헤더) 위젯 임포트
import 'ProfileWidgets/ProfileCompletedTab.dart'; // 완료된 미션 위젯 임포트
import 'ProfileWidgets/ProfileInProgressTab.dart'; // 진행중 미션 위젯 임포트

/// 프로필 메인 스크린
/// - 사용자 프로필 정보, 완료된/진행중 미션을 탭으로 나누어 표시
/// - 각 UI 구성 요소는 별도 파일로 모듈화되어 있음
class ProfileScreenMain extends StatefulWidget {
  const ProfileScreenMain({Key? key}) : super(key: key);

  @override
  State<ProfileScreenMain> createState() => _ProfileScreenMainState();
}

class _ProfileScreenMainState extends State<ProfileScreenMain>
    with SingleTickerProviderStateMixin {
  /// 탭 컨트롤러 (탭바 및 탭 뷰 전환용)
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 2개 (완료된 미션 / 진행중 미션)로 초기화
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // 탭 컨트롤러 해제 → 메모리 누수 방지
    _tabController.dispose();
    super.dispose();
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
          // 우측 상단 설정 아이콘 → SettingsScreen 이동
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onNavigateToHome: () {},
                    onNavigateToChat: () {},
                    onNavigateToMission: () {},
                    onNavigateToCommunity: () {},
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

          /// 상단 프로필 정보 (아이콘 + 사용자 이름)
          const ProfileHeader(),

          /// 탭바 (완료된 미션 / 진행중 미션)
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

          /// 탭 내용 영역 (TabBarView)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                /// 완료된 미션 탭 위젯
                ProfileCompletedTab(),

                /// 진행중 미션 탭 위젯
                ProfileInProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
