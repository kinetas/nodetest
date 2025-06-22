import 'package:flutter/material.dart';
import '../Mission/NewMissionScreen/AchievementPanel_screen.dart';
import '../CalendarScreen/WeeklyCalendarScreen.dart';
import '../Friends/FriendListWidget.dart';
import '../CalendarScreen/MonthlyCalendarScreen.dart';
import '../NewCommunity/LatestPostList.dart';
import '../Mission/NewMissionScreen/MyMissionList.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  HomeScreen({required this.onNavigateToCommunity});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAchievementPanel = false;
  DateTime? _selectedDate;

  void _toggleAchievementPanel() {
    setState(() {
      _showAchievementPanel = !_showAchievementPanel;
    });
  }

  Future<void> _onRefresh() async {
    // 🔄 새로고침 시 WeeklyCalendar와 친구목록, 최신글 등 필요한 상태 초기화
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '홈 화면',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            edgeOffset: 0,
            displacement: 50,
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // 🔄 필수: 안 내려가도 refresh 가능
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WeeklyCalendar(
                          onAddPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MonthlyCalendarScreen()),
                            );
                          },
                          onGraphPressed: _toggleAchievementPanel,
                          onDateSelected: (selected) {
                            setState(() {
                              _selectedDate = selected;
                            });
                          },
                        ),
                        if (_selectedDate != null)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: MyMissionList(
                                  key: ValueKey(_selectedDate),
                                  selectedDate: _selectedDate,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        LatestPosts(onNavigateToCommunity: widget.onNavigateToCommunity),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ];
              },
              body: FriendListWidget(),
            ),
          ),

          // ✅ 성취도 패널
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