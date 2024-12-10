import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리자

class WeeklyCalendar extends StatefulWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onGraphPressed;

  WeeklyCalendar({required this.onAddPressed, required this.onGraphPressed});

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  Map<String, int> taskCountPerDate = {}; // 날짜별 미션 개수 저장
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
  }

  Future<void> fetchAssignedMissions() async {
    final url = 'http://54.180.54.31:3000/api/missions/missions/assigned';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 날짜별 미션 개수 계산
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
    return taskCountPerDate[dateString] ?? 0; // 날짜의 미션 개수 반환 (없으면 0)
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
        'tasks': _getTaskCountForDate(currentDay), // API에서 받아온 미션 개수 사용
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