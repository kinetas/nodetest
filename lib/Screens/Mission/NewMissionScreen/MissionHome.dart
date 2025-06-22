import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MyMissionList.dart';
import '../../CalendarScreen/WeeklyCalendarScreen.dart';

class MissionHome extends StatefulWidget {
  @override
  _MissionHomeState createState() => _MissionHomeState();
}

class _MissionHomeState extends State<MissionHome> {
  DateTime? selectedDate;

  void _onDateSelected(DateTime? date) {
    setState(() {
      selectedDate = date ?? DateTime.now(); // 날짜 선택 없을 경우 오늘로 설정
    });
  }

  void _openGraph() {
    print("통계 보기 클릭됨");
  }

  void _createMission() {
    print("미션 생성 클릭됨");
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // 초기에는 오늘 날짜 미션 표시
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeeklyCalendar(
          onAddPressed: _createMission,
          onGraphPressed: _openGraph,
          onDateSelected: _onDateSelected,
          hideTopButtons: true, // ✅ 상단 버튼 숨기기
        ),
        const SizedBox(height: 8),
        Expanded(
          child: MyMissionList(
            selectedDate: selectedDate!,
            hideDateHeader: true,     // ✅ 날짜 헤더 숨김
            showMissionCount: false,  // ✅ 미션 수 숨김
          ),
        ),
      ],
    );
  }
}