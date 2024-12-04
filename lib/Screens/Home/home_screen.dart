import 'package:flutter/material.dart';
import '../Mission/AchievementPanel_screen.dart'; // AchievementPanel 파일을 임포트
import 'WeeklyCalendar_screen.dart';
import '../Friends/FriendList_widget.dart';
import 'MonthlyCalendar_screen.dart';
import '../Community/LatestPosts.dart'; // 최신 게시글 위젯 임포트

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  HomeScreen({required this.onNavigateToCommunity});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAchievementPanel = false;

  // 최신 게시글 데이터
  final List<Map<String, String>> latestPosts = [
    {'title': '최신 게시글 1', 'content': '이것은 첫 번째 최신 게시글입니다.'},
    {'title': '최신 게시글 2', 'content': '이것은 두 번째 최신 게시글입니다.'},
  ];

  void _toggleAchievementPanel() {
    setState(() {
      _showAchievementPanel = !_showAchievementPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.lightBlue[50]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '홈 화면',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 주간 캘린더
                      WeeklyCalendar(
                        onAddPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MonthlyCalendarScreen()),
                          );
                        },
                        onGraphPressed: _toggleAchievementPanel,
                      ),
                      SizedBox(height: 20),

                      // 최신 게시글

                      LatestPosts(
                        posts: latestPosts,
                        onNavigateToCommunity: widget.onNavigateToCommunity,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ];
            },
            body: FriendListWidget(), // 친구 목록을 스크롤 가능한 본체로 설정
          ),

          // 성취도 패널
          if (_showAchievementPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleAchievementPanel,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: AchievementPanel(
                      onClose: _toggleAchievementPanel,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}