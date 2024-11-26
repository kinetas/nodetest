import 'package:flutter/material.dart';

class TimeSettingScreen extends StatefulWidget {
  @override
  _TimeSettingScreenState createState() => _TimeSettingScreenState();
}

class _TimeSettingScreenState extends State<TimeSettingScreen> {
  DateTime selectedDate = DateTime.now();
  bool isAllDay = false;
  bool isToday = false;
  bool isTomorrow = false;
  bool isDayAfterTomorrow = false;
  int selectedHour = 0;
  int selectedMinute = 0;

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isToday = isTomorrow = isDayAfterTomorrow = false;
        if (isAllDay) {
          // "종일" 체크 시 날짜만 업데이트
          selectedHour = 23;
          selectedMinute = 59;
        }
      });
    }
  }

  void _toggleToday() {
    setState(() {
      isToday = !isToday;
      if (isToday) {
        selectedDate = DateTime.now();
        isTomorrow = isDayAfterTomorrow = false;
        if (isAllDay) {
          selectedHour = 23;
          selectedMinute = 59;
        }
      }
    });
  }

  void _toggleTomorrow() {
    setState(() {
      isTomorrow = !isTomorrow;
      if (isTomorrow) {
        selectedDate = DateTime.now().add(Duration(days: 1));
        isToday = isDayAfterTomorrow = false;
        if (isAllDay) {
          selectedHour = 23;
          selectedMinute = 59;
        }
      }
    });
  }

  void _toggleDayAfterTomorrow() {
    setState(() {
      isDayAfterTomorrow = !isDayAfterTomorrow;
      if (isDayAfterTomorrow) {
        selectedDate = DateTime.now().add(Duration(days: 2));
        isToday = isTomorrow = false;
        if (isAllDay) {
          selectedHour = 23;
          selectedMinute = 59;
        }
      }
    });
  }

  void _selectHour(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
    );
    if (picked != null) {
      setState(() {
        selectedHour = picked.hour;
      });
    }
  }

  void _selectMinute(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
    );
    if (picked != null) {
      setState(() {
        selectedMinute = picked.minute;
      });
    }
  }

  void _saveSettings() {
    Navigator.pop(context, {
      'selectedDate': selectedDate,
      'selectedHour': isAllDay ? 23 : selectedHour,
      'selectedMinute': isAllDay ? 59 : selectedMinute,
      'isAllDay': isAllDay,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('시간 설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: isToday || isTomorrow || isDayAfterTomorrow ? null : () => _selectDate(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text("${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일"),
          ),
          Row(
            children: [
              Checkbox(value: isToday, onChanged: (value) => _toggleToday()),
              Text("오늘"),
              Checkbox(value: isTomorrow, onChanged: (value) => _toggleTomorrow()),
              Text("내일"),
              Checkbox(value: isDayAfterTomorrow, onChanged: (value) => _toggleDayAfterTomorrow()),
              Text("모레"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: isAllDay ? null : () => _selectHour(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text("${selectedHour.toString().padLeft(2, '0')}시"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: isAllDay ? null : () => _selectMinute(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text("${selectedMinute.toString().padLeft(2, '0')}분"),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: isAllDay,
                onChanged: (value) {
                  setState(() {
                    isAllDay = value ?? false;
                    if (isAllDay) {
                      selectedHour = 23;
                      selectedMinute = 59;
                    }
                  });
                },
              ),
              Text("종일"),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("취소"),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text("저장"),
        ),
      ],
    );
  }
}