import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import '../../SessionCookieManager.dart';

class MyMissionList extends StatefulWidget {
  @override
  _MyMissionListState createState() => _MyMissionListState();
}

class _MyMissionListState extends State<MyMissionList> {
  List<Map<String, dynamic>> missions = []; // 모든 미션 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리
  String currentUserId = 'your_user_id'; // 현재 사용자 ID (필요시 업데이트)

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 모든 데이터를 가져와 저장
        final List<Map<String, dynamic>> fetchedMissions =
        (responseData['missions'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          missions = fetchedMissions;
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
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (missions.isEmpty) {
      return Scaffold(
        body: Center(child: Text('미션 없음')),
      );
    }

    final today = DateTime.now();
    final currentYear = today.year.toString();
    String previousYear = '';

    // 데드라인 기준으로 정렬
    missions.sort((a, b) {
      final dateA = DateTime.parse(a['m_deadline']);
      final dateB = DateTime.parse(b['m_deadline']);
      return dateA.compareTo(dateB);
    });

    final List<Widget> missionWidgets = [];
    String previousDate = '';

    for (var mission in missions) {
      final missionDate = DateTime.parse(mission['m_deadline']);
      final formattedDate = DateFormat('MM/dd (E)', 'ko_KR').format(missionDate);
      final missionYear = missionDate.year.toString();

      // 년도 헤더 추가 (현재 연도는 표시하지 않음)
      if (missionYear != previousYear) {
        previousYear = missionYear;
        if (missionYear != currentYear) {
          missionWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                missionYear,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }

      // 날짜 헤더 추가
      if (formattedDate != previousDate) {
        previousDate = formattedDate;
        missionWidgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formattedDate,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      missionWidgets.add(MissionCard(
        mission: mission,
        currentUserId: currentUserId,
      ));
    }

    return Scaffold(
      body: ListView(
        children: missionWidgets,
      ),
    );
  }
}

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
        title: Text(mission['m_title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('마감 기한: ${formatTime(mission['m_deadline'])}'),
            Text('미션 생성자: ${isPersonalMission ? "개인미션" : mission['u1_id']}'),
            Text('미션 상태: ${mission['m_status']}'),
          ],
        ),
      ),
    );
  }

  String formatTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid time';
    }
  }
}