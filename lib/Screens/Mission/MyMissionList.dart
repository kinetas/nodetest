import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위해 추가
import '../../SessionCookieManager.dart';

class MyMissionList extends StatefulWidget {
  @override
  _MyMissionListState createState() => _MyMissionListState();
}

class _MyMissionListState extends State<MyMissionList> {
  List<Map<String, dynamic>> missions = []; // 미션 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchMissions(); // API 호출
  }

  Future<void> fetchMissions() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/missions/missions/assigned',
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          missions = (responseData['missions'] as List<dynamic>).map((item) {
            return {
              'm_id': item['m_id'] ?? 'No ID',
              'm_title': item['m_title'] ?? 'No Title',
              'm_deadline': item['m_deadline'] ?? 'No Deadline',
              'm_status': item['m_status'] ?? 'No Status',
              'r_id': item['r_id'] ?? 'No Room ID',
              'r_title': item['r_title'] ?? 'No Room Title',
            };
          }).toList();
          isLoading = false;
        });
      } else {
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
        title: Text('미션 목록'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : missions.isEmpty
          ? Center(child: Text('미션 없음')) // 데이터가 없을 때
          : ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(mission['m_title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deadline: ${mission['m_deadline']}'),
                  Text('Status: ${mission['m_status']}'),
                  Text('Room: ${mission['r_title']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}