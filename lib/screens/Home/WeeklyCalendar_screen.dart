import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MonthlyCalendar_screen.dart';

class WeeklyCalendar extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onGraphPressed;

  WeeklyCalendar({required this.onAddPressed, required this.onGraphPressed});

  List<Map<String, dynamic>> _generateWeeklyData() {
    List<Map<String, dynamic>> weekData = [];
    DateTime today = DateTime.now();
    List<String> daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

    for (int i = 0; i < 7; i++) {
      DateTime currentDay = today.add(Duration(days: i - today.weekday + 1));
      weekData.add({
        'day': daysOfWeek[currentDay.weekday % 7],
        'date': DateFormat('MM/dd').format(currentDay),
        'tasks': _getTasksForDay(currentDay), // 할 일 개수를 반환하는 함수
      });
    }
    return weekData;
  }

  int _getTasksForDay(DateTime date) {
    return date.day % 3 + 1;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> weekData = _generateWeeklyData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('주간 캘린더', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.bar_chart),
                  onPressed: onGraphPressed, // 달성률 버튼을 눌렀을 때 패널 토글
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: onAddPressed,
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekData.map((dayData) {
            return Column(
              children: [
                Text(dayData['day'], style: TextStyle(fontSize: 16)),
                Text(dayData['date'], style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 5),
                Text('${dayData['tasks']} 개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

