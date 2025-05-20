/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import 'MyMissionClick.dart'; // MissionClick 화면 import

class MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final String currentUserId;

  MissionCard({required this.mission, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isPersonalMission = mission['u1_id'] == currentUserId;
    final isRequesting = mission['m_status'] == "요청중"; // 상태가 "요청중"인지 확인

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            mission['m_title'] ?? '제목 없음',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey.shade900,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마감 기한: ${formatTime(mission['m_deadline'])}',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text(
                  '미션 생성자: ${isPersonalMission ? "개인미션" : mission['u1_id'] ?? "알 수 없음"}',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text(
                  '미션 상태: ${mission['m_status'] ?? "상태 없음"}',
                  style: TextStyle(
                    color: isRequesting ? Colors.red : Colors.blueGrey, // 요청중일 경우 빨간색
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isRequesting ? Colors.grey : Colors.lightBlue, // 요청중일 경우 회색으로 비활성화 느낌
            size: 20,
          ),
          onTap: isRequesting
              ? null // 요청중일 경우 클릭 비활성화
              : () {
            // MissionClick 팝업 창 띄우기
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return MissionClick(mission: mission); // MissionClick에 미션 데이터 전달
              },
            );
          },
        ),
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
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MyMissionClick.dart';

class MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final String currentUserId;

  const MissionCard({
    required this.mission,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isPersonalMission = mission['u1_id'] == currentUserId;
    final isRequesting = mission['m_status'] == "요청중";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isRequesting ? Colors.grey.shade300 : Colors.lightBlue.shade100,
          width: 1.5,
        ),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          mission['m_title'] ?? '제목 없음',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueGrey.shade900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '마감 기한: ${formatTime(mission['m_deadline'])}',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              Text(
                '미션 생성자: ${isPersonalMission ? "개인미션" : mission['u1_id'] ?? "알 수 없음"}',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              Text(
                '미션 상태: ${mission['m_status'] ?? "상태 없음"}',
                style: TextStyle(
                  color: isRequesting ? Colors.red : Colors.blueGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isRequesting ? Colors.grey : Colors.lightBlue,
          size: 20,
        ),
        onTap: isRequesting
            ? null
            : () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MissionClick(mission: mission);
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
      final dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print('Invalid date format: $dateString, error: $e');
      return '유효하지 않은 날짜';
    }
  }
}