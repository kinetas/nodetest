import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리 클래스

class RequestedMissionScreen extends StatefulWidget {
  @override
  _RequestedMissionScreenState createState() => _RequestedMissionScreenState();
}

class _RequestedMissionScreenState extends State<RequestedMissionScreen> {
  List<Map<String, dynamic>> requestedMissions = []; // 요청된 미션 데이터 저장
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchRequestedMissions(); // API 호출
  }

  // API 데이터 가져오기
  Future<void> fetchRequestedMissions() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/missions/missions/created_req',
      );

      if (response.statusCode == 200) {
        final List<dynamic> missions = jsonDecode(response.body)['missions'];

        setState(() {
          requestedMissions = missions.map((mission) {
            return {
              'm_id': mission['m_id'] ?? 'No ID',
              'm_title': mission['m_title'] ?? 'No Title',
              'm_deadline': mission['m_deadline'] ?? 'No Deadline',
              'm_status': mission['m_status'] ?? 'No Status',
              't_title': mission['t_title'] ?? 'No Target Title',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // 배경색 설정
      appBar: AppBar(
        title: Text(
          '요청된 미션',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue[400],
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue[400],
        ),
      )
          : requestedMissions.isEmpty
          ? Center(
        child: Text(
          '요청된 미션이 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: requestedMissions.length,
        itemBuilder: (context, index) {
          final mission = requestedMissions[index];
          return Card(
            elevation: 3,
            margin:
            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                mission['m_title'], // 미션 제목
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    '마감일: ${formatDate(mission['m_deadline'])}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '상태: ${mission['m_status']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '타겟: ${mission['t_title']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.pending_actions,
                color: Colors.orange,
              ),
              onTap: () => _showMissionDialog(context, mission),
            ),
          );
        },
      ),
    );
  }

  // 작은 창을 표시하는 함수
  void _showMissionDialog(BuildContext context, Map<String, dynamic> mission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "미션 처리",
            style: TextStyle(color: Colors.lightBlue[800]),
          ),
          content: Text("미션 '${mission['m_title']}'를 처리하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 확인 창 닫기
                _showConfirmationDialog(context, mission, '성공');
              },
              child: Text(
                "성공",
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 확인 창 닫기
                _showConfirmationDialog(context, mission, '실패');
              },
              child: Text(
                "실패",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // 확인 메시지 창
  void _showConfirmationDialog(
      BuildContext context, Map<String, dynamic> mission, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "확인",
            style: TextStyle(color: Colors.lightBlue[800]),
          ),
          content: Text("정말 '${mission['m_title']}' 미션을 $result 처리하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 확인 창 닫기
                _processMission(mission, result);
              },
              child: Text(
                "예",
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // 확인 창 닫기
              child: Text(
                "아니오",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // 미션 처리 함수
  Future<void> _processMission(
      Map<String, dynamic> mission, String result) async {
    final url = result == '성공'
        ? 'http://54.180.54.31:3000/api/missions/successMission'
        : 'http://54.180.54.31:3000/api/missions/failureMission';

    final requestData = {
      'm_id': mission['m_id'],
    };

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("미션이 $result 처리되었습니다.")),
        );
        setState(() {
          requestedMissions.remove(mission); // 처리된 미션 제거
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("미션 처리에 실패했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("미션 처리 중 오류가 발생했습니다.")),
      );
    }
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