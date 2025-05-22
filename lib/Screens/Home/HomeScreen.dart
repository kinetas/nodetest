import 'package:flutter/material.dart';
import '../Mission/AchievementPanel_screen.dart';
import '../CalendarScreen/WeeklyCalendarScreen.dart';
import '../Friends/FriendListWidget.dart';
import '../CalendarScreen/MonthlyCalendarScreen.dart';
import '../Community/LatestPostList.dart';
import '../Mission/MyMission/MyMissionList.dart';

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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.white;

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
                      // ✅ 주간 캘린더
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

                      // ✅ 드롭다운 영역 (선택된 날짜의 미션)
                      if (_selectedDate != null)
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
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

                      SizedBox(height: 20),

                      // ✅ 최신 게시글
                      LatestPosts(
                        onNavigateToCommunity: widget.onNavigateToCommunity,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ];
            },
            body: FriendListWidget(),
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