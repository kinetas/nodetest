import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      'isAllDay': isAllDay,
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay temp = selectedTime;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('시간 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(hours: selectedTime.hour, minutes: selectedTime.minute),
                onTimerDurationChanged: (duration) {
                  temp = TimeOfDay(hour: duration.inHours, minute: duration.inMinutes % 60);
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedTime = temp;
                  isAllDay = false;
                });
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, DateTime date) {
    final isSelected = selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => selectedDate = date),
      selectedColor: Colors.blue.shade100,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade800 : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '미션 마감 시간 설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 날짜 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("마감 날짜", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  TextButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      "${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickDateButton("오늘", DateTime.now()),
                  _buildQuickDateButton("내일", DateTime.now().add(const Duration(days: 1))),
                  _buildQuickDateButton("모레", DateTime.now().add(const Duration(days: 2))),
                ],
              ),

              const SizedBox(height: 24),

              // 시간 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("시간 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  isAllDay
                      ? const Text("종일", style: TextStyle(color: Colors.grey, fontSize: 15))
                      : Text(
                    "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  TextButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: const Text("설정", style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),

              // 종일 여부
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isAllDay,
                onChanged: (v) => setState(() => isAllDay = v),
                title: const Text("종일로 설정"),
              ),
              const SizedBox(height: 24),

              // 버튼 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("취소", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("저장", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}