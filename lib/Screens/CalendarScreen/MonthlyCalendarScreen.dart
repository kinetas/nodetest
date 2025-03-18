import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리자
import 'dart:convert';

class MonthlyCalendarScreen extends StatefulWidget {
  @override
  _MonthlyCalendarScreenState createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  Map<String, int> taskCountPerDate = {}; // 날짜별 미션 개수
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
  }

  Future<void> fetchAssignedMissions() async {
    final url = 'http://27.113.11.48:3000/api/missions/missions/assigned';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

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

  List<List<DateTime?>> _generateMonthlyCalendar(DateTime month) {
    List<List<DateTime?>> calendar = [];
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 시작일과 끝일 맞추기 위해 추가된 전후 날짜
    DateTime startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday));
    DateTime endDate = lastDayOfMonth.add(Duration(days: 6 - lastDayOfMonth.weekday));

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      List<DateTime?> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate.month == month.month ? currentDate : null);
        currentDate = currentDate.add(Duration(days: 1));
      }
      calendar.add(week);
    }

    return calendar;
  }

  int _getTaskCountForDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return taskCountPerDate[dateString] ?? 0; // 해당 날짜의 미션 개수 반환 (없으면 0)
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monthlyCalendar = _generateMonthlyCalendar(today);

    return Scaffold(
      appBar: AppBar(
        title: Text('월간 캘린더'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              DateFormat('yyyy년 MM월').format(today),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Table(
              columnWidths: const {
                0: FractionColumnWidth(1 / 7),
                1: FractionColumnWidth(1 / 7),
                2: FractionColumnWidth(1 / 7),
                3: FractionColumnWidth(1 / 7),
                4: FractionColumnWidth(1 / 7),
                5: FractionColumnWidth(1 / 7),
                6: FractionColumnWidth(1 / 7),
              },
              children: [
                TableRow(
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .map((day) => Center(
                    child: Text(
                      day,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ))
                      .toList(),
                ),
                ...monthlyCalendar.map(
                      (week) => TableRow(
                    children: week.map((date) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Text(
                              date != null ? date.day.toString() : '',
                              style: TextStyle(
                                color: date?.month == today.month ? Colors.black : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              date != null ? '${_getTaskCountForDate(date)}개' : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: date?.month == today.month ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}