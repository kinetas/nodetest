/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 수정

class WeeklyCalendar extends StatefulWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onGraphPressed;

  WeeklyCalendar({required this.onAddPressed, required this.onGraphPressed});

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  Map<String, int> taskCountPerDate = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
  }

  Future<void> fetchAssignedMissions() async {
    final url = 'http://27.113.11.48:3000/api/missions/missions/assigned';

    try {
      final response = await SessionTokenManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Map<String, int> tempTaskCount = {};
        for (var mission in data) {
          final deadline = mission['m_deadline'];
          if (deadline != null) {
            final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(deadline));
            tempTaskCount[date] = (tempTaskCount[date] ?? 0) + 1;
          }
        }

        setState(() {
          taskCountPerDate = tempTaskCount;
          isLoading = false;
        });
      } else {
        print('Failed to fetch missions: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching missions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _getTaskCountForDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return taskCountPerDate[dateString] ?? 0;
  }

  List<Map<String, dynamic>> _generateWeeklyData() {
    List<Map<String, dynamic>> weekData = [];
    DateTime today = DateTime.now();
    List<String> daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

    for (int i = 0; i < 7; i++) {
      DateTime currentDay = today.add(Duration(days: i - today.weekday + 1));
      weekData.add({
        'day': daysOfWeek[currentDay.weekday % 7],
        'date': DateFormat('MM/dd').format(currentDay),
        'tasks': _getTaskCountForDate(currentDay),
      });
    }
    return weekData;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue[300]!;
    final Color backgroundColor = Colors.white;
    final Color accentColor = Colors.lightBlue[100]!;

    List<Map<String, dynamic>> weekData = _generateWeeklyData();

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주간 캘린더',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.bar_chart, color: primaryColor),
                    onPressed: widget.onGraphPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: primaryColor),
                    onPressed: widget.onAddPressed,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekData.map((dayData) {
              return Column(
                children: [
                  Text(
                    dayData['day'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    dayData['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '${dayData['tasks']} 개',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class WeeklyCalendar extends StatefulWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onGraphPressed;
  final void Function(DateTime?)? onDateSelected;

  WeeklyCalendar({
    required this.onAddPressed,
    required this.onGraphPressed,
    this.onDateSelected,
  });

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  Map<String, int> taskCountPerDate = {};
  bool isLoading = true;

  DateTime today = DateTime.now();
  DateTime? selectedDate;
  int currentPage = 10000;
  PageController _pageController = PageController(initialPage: 10000);

  int displayYear = DateTime.now().year;
  int displayMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
    selectedDate = today;
  }

  Future<void> fetchAssignedMissions() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/missions/missions/assigned';

    try {
      final response = await SessionTokenManager.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> missionList = responseData['missions'] ?? [];

        Map<String, int> tempTaskCount = {};
        for (var item in missionList) {
          final mission = item as Map<String, dynamic>;
          final deadline = mission['m_deadline'];
          if (deadline != null) {
            final date = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(deadline).toLocal());
            tempTaskCount[date] = (tempTaskCount[date] ?? 0) + 1;
          }
        }

        setState(() {
          taskCountPerDate = tempTaskCount;
          isLoading = false;
        });
      } else {
        print('Failed to fetch missions: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching missions: $e');
      setState(() => isLoading = false);
    }
  }

  int _getTaskCountForDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return taskCountPerDate[dateString] ?? 0;
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _goToToday() {
    setState(() {
      selectedDate = today;
      currentPage = 10000;
      displayYear = today.year;
      displayMonth = today.month;
      _pageController.jumpToPage(currentPage);
    });

    if (widget.onDateSelected != null) {
      widget.onDateSelected!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color selectedColor = Colors.cyan;

    DateTime currentWeekStart = _getStartOfWeek(
        today.add(Duration(days: (currentPage - 10000) * 7)));

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
      padding: EdgeInsets.all(12),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    '$displayYear년 $displayMonth월',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: primaryColor),
                    onPressed: _goToToday,
                  ),
                  IconButton(
                    icon: Icon(Icons.bar_chart, color: primaryColor),
                    onPressed: widget.onGraphPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: primaryColor),
                    onPressed: widget.onAddPressed,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                  DateTime weekStart = _getStartOfWeek(
                      today.add(Duration(days: (index - 10000) * 7)));
                  displayYear = weekStart.year;
                  displayMonth = weekStart.month;
                });
              },
              itemBuilder: (context, index) {
                DateTime weekStart = _getStartOfWeek(
                    today.add(Duration(days: (index - 10000) * 7)));

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (dayOffset) {
                    DateTime date =
                    weekStart.add(Duration(days: dayOffset));
                    bool isToday = date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    bool isSelected = selectedDate != null &&
                        date.year == selectedDate!.year &&
                        date.month == selectedDate!.month &&
                        date.day == selectedDate!.day;

                    int taskCount = _getTaskCountForDate(date);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        if (widget.onDateSelected != null) {
                          widget.onDateSelected!(date);
                        }
                      },
                      child: Container(
                        width: 50,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: isToday
                              ? Border.all(
                              color: selectedColor, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E('ko_KR').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (date.weekday ==
                                    DateTime.sunday
                                    ? Colors.red
                                    : date.weekday ==
                                    DateTime.saturday
                                    ? Colors.blue
                                    : Colors.black),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${taskCount}개',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}