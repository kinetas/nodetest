import 'package:flutter/material.dart';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리자
import 'TimeSettingScreen.dart'; // 시간 설정 화면
import 'dart:convert';

class MissionCreateScreen extends StatefulWidget {
  @override
  _MissionCreateScreenState createState() => _MissionCreateScreenState();
}

class _MissionCreateScreenState extends State<MissionCreateScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();
  final TextEditingController u2IdController = TextEditingController(); // 상대방 ID 입력 필드

  String? u1Id; // 사용자 ID
  bool isLoading = true; // 로딩 상태 플래그
  bool isForOtherUser = false; // 체크박스 상태

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // u1_id 불러오기
  Future<void> _fetchUserId() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/user-info/user-id',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('응답 데이터: $responseData');
        setState(() {
          u1Id = responseData['u_id'];
          isLoading = false;
        });
      } else {
        print('Failed to fetch user ID: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user ID: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 미션 생성 API 호출
  Future<void> _createMission() async {
    if (u1Id == null) {
      print('u1_id is not loaded yet.');
      return;
    }

    final missionData = {
      "u1_id": u1Id,
      "u2_id": isForOtherUser ? u2IdController.text : u1Id,
      "m_title": titleController.text,
      "m_deadline": deadlineController.text,
      "m_reword": rewardController.text.isEmpty ? null : rewardController.text,
    };

    try {
      final response = await SessionCookieManager.post(
        'http://54.180.54.31:3000/api/missions/missioncreate',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(missionData),
      );

      if (response.statusCode == 200) {
        print('Mission created successfully!');
        // 성공 시 추가 로직
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션이 성공적으로 생성되었습니다!')),
        );
      } else {
        print('Failed to create mission: ${response.body}');
      }
    } catch (error) {
      print('Error creating mission: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 생성'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '미션 제목'),
            ),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(labelText: '미션 기한'),
              onTap: () async {
                final selectedTime = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TimeSettingScreen()),
                );
                if (selectedTime != null) {
                  deadlineController.text = selectedTime;
                }
              },
            ),
            TextField(
              controller: rewardController,
              decoration: InputDecoration(labelText: '보상'),
            ),
            CheckboxListTile(
              title: Text('상대방에게 할당'),
              value: isForOtherUser,
              onChanged: (value) {
                setState(() {
                  isForOtherUser = value!;
                });
              },
            ),
            if (isForOtherUser)
              TextField(
                controller: u2IdController,
                decoration: InputDecoration(labelText: '상대방 ID'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: u1Id == null ? null : _createMission, // u1_id 없을 시 비활성화
              child: Text('미션 생성'),
            ),
          ],
        ),
      ),
    );
  }
}