/*
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // 날짜 포맷 변경을 위한 패키지
import '../../../SessionTokenManager.dart';

class MyCompleteMissionList extends StatefulWidget {
  @override
  _MyCompleteMissionListState createState() => _MyCompleteMissionListState();
}

class _MyCompleteMissionListState extends State<MyCompleteMissionList> {
  List<Map<String, dynamic>> completedMissions = []; // 완료된 미션 저장
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchCompletedMissions(); // API 호출
  }

  Future<void> fetchCompletedMissions() async {
    try {
      // SessionTokenManager를 활용하여 API 호출
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/api/missions/missions/completed',
      );

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져온 경우
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> missions = responseData['missions'];

        setState(() {
          completedMissions = missions.map((mission) {
            return {
              'm_id': mission['m_id'] ?? '',
              'u1_id': mission['u1_id'] ?? '',
              'u2_id': mission['u2_id'] ?? '',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? '',
              'm_reword': mission['m_reword'] ?? '',
              'm_status': mission['m_status'] ?? '',
              'r_id': mission['r_id'] ?? '',
              'm_extended': mission['m_extended'] ?? false,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        // 실패한 경우
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load completed missions. Status code: ${response.statusCode}');
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
      backgroundColor: Colors.white, // 배경색

      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : completedMissions.isEmpty
          ? Center(
        child: Text(
          '완료된 미션이 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: completedMissions.length,
        itemBuilder: (context, index) {
          final mission = completedMissions[index];
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
                title: Text(
                  mission['m_title'], // 미션 제목
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '마감일: ${formatDate(mission['m_deadline'])}',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        '리워드: ${mission['m_reword']}',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        '상태: ${mission['m_status']}',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      Text(
                        '추가시간 사용: ${mission['m_extended'] ? "예" : "아니오"}',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.check_circle, color: Colors.green, size: 28), // 완료 아이콘
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
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // 예: 2024-11-29 14:56
    } catch (e) {
      return 'Invalid date';
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../SessionTokenManager.dart';

class MyCompleteMissionList extends StatefulWidget {
  @override
  _MyCompleteMissionListState createState() => _MyCompleteMissionListState();
}

class _MyCompleteMissionListState extends State<MyCompleteMissionList> {
  List<Map<String, dynamic>> completedMissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedMissions();
  }

  Future<void> fetchCompletedMissions() async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/api/missions/missions/completed',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> missions = responseData['missions'];

        setState(() {
          completedMissions = missions.map((mission) {
            return {
              'm_id': mission['m_id'] ?? '',
              'u1_id': mission['u1_id'] ?? '',
              'u2_id': mission['u2_id'] ?? '',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? '',
              'm_reword': mission['m_reword'] ?? '',
              'm_status': mission['m_status'] ?? '',
              'r_id': mission['r_id'] ?? '',
              'm_extended': mission['m_extended'] ?? false,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load completed missions. Status code: ${response.statusCode}');
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
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : completedMissions.isEmpty
          ? Center(
        child: Text(
          '완료된 미션이 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: completedMissions.length,
        itemBuilder: (context, index) {
          final mission = completedMissions[index];
          final status = mission['m_status'];
          final isSuccess = status == '성공';
          final cardColor = isSuccess
              ? Colors.lightBlue.shade100
              : Colors.red.shade100;

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: cardColor,
            child: ListTile(
              title: Text(
                mission['m_title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '마감일: ${formatDate(mission['m_deadline'])}',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      '리워드: ${mission['m_reword']}',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      '상태: ${mission['m_status']}',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      '추가시간 사용: ${mission['m_extended'] ? "예" : "아니오"}',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              trailing: Icon(
                Icons.check_circle,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}