import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import 'MyMissionClick.dart'; // MissionClick 화면 import

class MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final String currentUserId;

  MissionCard({required this.mission, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isPersonalMission = mission['u1_id'] == currentUserId;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(mission['m_title'] ?? '제목 없음'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('마감 기한: ${formatTime(mission['m_deadline'])}'),
            Text('미션 생성자: ${isPersonalMission ? "개인미션" : mission['u1_id'] ?? "알 수 없음"}'),
            Text('미션 상태: ${mission['m_status'] ?? "상태 없음"}'),
          ],
        ),
        onTap: () {
          // MissionClick 팝업 창 띄우기
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MissionClick(mission: mission); // MissionClick에 미션 데이터 전달
            },
          );
        },
      ),
    );
  }

  String formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '기한 없음';
    }
    try {
      // 날짜 파싱 시도
      final dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print('Invalid date format: $dateString, error: $e');
      return '유효하지 않은 날짜';
    }
  }
}