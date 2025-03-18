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
        'http://27.113.11.48:3000/api/missions/missions/created',
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          missions = (responseData['missions'] as List<dynamic>).map((mission) {
            return {
              'm_id': mission['m_id'] ?? 'No ID',
              'u1_id': mission['u1_id'] ?? 'No Creator ID',
              'u2_id': mission['u2_id'] ?? 'No Assignee ID',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? 'No Deadline',
              'm_reword': mission['m_reword'] ?? 'No Reward',
              'm_status': mission['m_status'] ?? 'No Status',
              'r_id': mission['r_id'] ?? 'No Room ID',
              'm_extended': mission['m_extended'] ?? 'No Extension Info',
              'missionAuthenticationAuthority': mission['missionAuthenticationAuthority'] ?? 'No Authority',
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
      backgroundColor: Colors.lightBlue.shade50, // 배경색 설정

      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : missions.isEmpty
          ? Center(
        child: Text(
          '부여된 미션이 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
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
                  mission['m_title'], // 미션 제목
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
                        '마감일: ${formatDate(mission['m_deadline'])}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '상태: ${mission['m_status']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '보상: ${mission['m_reword']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '방 ID: ${mission['r_id']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '연장 여부: ${mission['m_extended']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '인증 권한자: ${mission['missionAuthenticationAuthority']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '생성자 ID: ${mission['u1_id']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                      Text(
                        '수행자 ID: ${mission['u2_id']}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.assignment, color: Colors.lightBlue, size: 28), // 아이콘
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