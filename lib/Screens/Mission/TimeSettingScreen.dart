import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSettingScreen extends StatefulWidget {
  @override
  _TimeSettingScreenState createState() => _TimeSettingScreenState();
}

class _TimeSettingScreenState extends State<TimeSettingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAllDay = false;

  void _saveSettings() {
    Navigator.pop(context, {
      'selectedDate': selectedDate,
      'selectedHour': isAllDay ? 23 : selectedTime.hour,
      'selectedMinute': isAllDay ? 59 : selectedTime.minute,
      'isAllDay': isAllDay, // "종일" 여부를 결과에 포함
    });
  }

  Future<void> _showCalendarPopup() async {
    DateTime tempSelectedDate = selectedDate;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8, // 팝업 높이 조정
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "날짜 선택",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: TableCalendar(
                        focusedDay: tempSelectedDate,
                        firstDay: DateTime.now(), // 오늘 이전 날짜 비활성화
                        lastDay: DateTime(2100),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.3),
                            border: Border.all(color: Colors.blue, width: 2),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(color: Colors.black),
                          disabledTextStyle: TextStyle(color: Colors.grey),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false, // 2주 보기 버튼 제거
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setDialogState(() {
                            tempSelectedDate = selectedDay;
                          });
                        },
                        selectedDayPredicate: (day) => isSameDay(day, tempSelectedDate),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "취소",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = tempSelectedDate; // 선택한 날짜를 저장
                            });
                            Navigator.pop(context); // 팝업 닫기
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "확인",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7, // 다이얼로그 높이
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간 설정',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "날짜 선택",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _showCalendarPopup,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateButton('오늘', DateTime.now()),
                _buildDateButton('내일', DateTime.now().add(Duration(days: 1))),
                _buildDateButton('모레', DateTime.now().add(Duration(days: 2))),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "시간 선택",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isAllDay
                            ? '종일'
                            : '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Checkbox(
                  value: isAllDay,
                  onChanged: (value) {
                    setState(() {
                      isAllDay = value ?? false;
                    });
                  },
                ),
                Text("종일", style: TextStyle(fontSize: 16)),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "저장",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime date) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedDate = date;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSameDay(selectedDate, date)
            ? Colors.blueAccent
            : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSameDay(selectedDate, date) ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}