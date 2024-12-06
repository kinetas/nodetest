import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리 클래스

class GiveCompleteMissionList extends StatefulWidget {
  @override
  _GiveCompleteMissionListState createState() => _GiveCompleteMissionListState();
}

class _GiveCompleteMissionListState extends State<GiveCompleteMissionList> {
  List<Map<String, dynamic>> completedMissions = []; // 완료된 미션 데이터 저장
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchCompletedMissions(); // API 호출
  }

  // API 데이터 가져오기
  Future<void> fetchCompletedMissions() async {
    try {
      // SessionCookieManager 활용하여 세션 쿠키 포함 요청
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/missions/missions/givenCompleted',
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져온 경우
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          completedMissions = (responseData['missions'] as List<dynamic>).map((mission) {
            return {
              'm_id': mission['m_id'] ?? 'No ID',
              'u1_id': mission['u1_id'] ?? 'No User ID',
              'u2_id': mission['u2_id'] ?? 'No Other User ID',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? 'No Deadline',
              'm_reword': mission['m_reword'] ?? 'No Reward',
              'm_status': mission['m_status'] ?? 'No Status',
              'r_id': mission['r_id'] ?? 'No Room ID',
              'm_extended': mission['m_extended'] ?? false,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        // 서버 응답 실패
        setState(() {
          isLoading = false;
        });
        print('Failed to load completed missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching completed missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상대방이 완료한 미션'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : completedMissions.isEmpty
          ? Center(child: Text('상대방이 완료한 미션이 없습니다.'))
          : ListView.builder(
        itemCount: completedMissions.length,
        itemBuilder: (context, index) {
          final mission = completedMissions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                mission['m_title'], // 미션 제목
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('마감일: ${formatDate(mission['m_deadline'])}'),
                  Text('리워드: ${mission['m_reword']}'),
                  Text('상태: ${mission['m_status']}'),
                  Text('부여자 ID: ${mission['u1_id']}'),
                  Text('수행자 ID: ${mission['u2_id']}'),
                  Text('방 ID: ${mission['r_id']}'),
                  Text('추가시간 사용: ${mission['m_extended'] ? "예" : "아니오"}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 날짜 포맷 변경 함수
  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Invalid date';
    }
  }
}