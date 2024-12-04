import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyCalendarScreen extends StatelessWidget {
  List<List<DateTime?>> _generateMonthlyCalendar(DateTime month) {
    List<List<DateTime?>> calendar = [];
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 시작일과 끝일을 맞추기 위해 추가된 전후 날짜
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
    // 임의의 미션 개수 반환 (실제 데이터와 연동 가능)
    return date.day % 3 + 1;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<List<DateTime?>> monthlyCalendar = _generateMonthlyCalendar(today);

    return Scaffold(
      appBar: AppBar(
        title: Text('월간 캘린더'),
      ),
      body: Padding(
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
                      .map((day) => Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold))))
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