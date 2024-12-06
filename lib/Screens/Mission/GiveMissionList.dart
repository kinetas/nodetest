import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // SessionCookieManager를 import

class GiveMissionList extends StatefulWidget {
  @override
  _GiveMissionListState createState() => _GiveMissionListState();
}

class _GiveMissionListState extends State<GiveMissionList> {
  List<Map<String, dynamic>> missions = []; // 미션 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchMissions(); // API 호출
  }

  // API 데이터 가져오기 (SessionCookieManager 사용)
  Future<void> fetchMissions() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/missions/missions/created',
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져온 경우
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          missions = (responseData['missions'] as List<dynamic>).map((mission) {
            return {
              'm_id': mission['m_id'] ?? 'No ID',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? 'No Deadline',
              'm_status': mission['m_status'] ?? 'No Status',
              'r_id': mission['r_id'] ?? 'No Room ID',
              'r_title': mission['r_title'] ?? 'No Room Title',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        // 서버 응답 실패
        setState(() {
          isLoading = false;
        });
        print('Failed to load missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('부여한 미션 목록'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : missions.isEmpty
          ? Center(child: Text('부여된 미션이 없습니다.')) // 미션이 없을 때
          : ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
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
                  Text('상태: ${mission['m_status']}'),
                  Text('방 ID: ${mission['r_id']}'),
                  Text('방 제목: ${mission['r_title']}'),
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