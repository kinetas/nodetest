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
      // SessionCookieManager의 정적 메서드 get 호출
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/missions/missions/assigned', // String URL 사용
      );

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져온 경우
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          missions = data.map((item) {
            return {
              'title': item['title'] ?? 'No Title',
              'dueDate': item['dueDate'] ?? 'No Due Date',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        // 서버 응답이 실패했을 때
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load missions. Status code: ${response.statusCode}');
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
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // 로딩 중일 때
    }

    if (missions.isEmpty) {
      return Center(child: Text('미션 없음')); // 미션이 없을 때
    }

    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return ListTile(
          title: Text(mission['title']),
          subtitle: Text(mission['dueDate']),
        );
      },
    );
  }
}