import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        'tasks': _getTasksForDay(currentDay),
      });
    }
    return weekData;
  }

  int _getTasksForDay(DateTime date) {
    return date.day % 3 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue[300]!;
    final Color backgroundColor = Colors.white;
    final Color accentColor = Colors.lightBlue[100]!;

    List<Map<String, dynamic>> weekData = _generateWeeklyData();

    return Container(
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
                    onPressed: onGraphPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: primaryColor),
                    onPressed: onAddPressed,
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