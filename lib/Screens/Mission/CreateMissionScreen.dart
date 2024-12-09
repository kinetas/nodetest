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
  final TextEditingController u2IdController = TextEditingController(); // u2_id 입력
  final TextEditingController authenticationController = TextEditingController(); // authenticationAuthority 입력

  bool isMyMission = false; // 내 미션 여부
  bool isShareMission = false; // 미션 공유 여부

  // 미션 생성 API 호출
  Future<void> _createMission() async {
    final missionData = {
      "u2_id": isMyMission ? null : u2IdController.text,
      "authenticationAuthority": isMyMission && isShareMission
          ? authenticationController.text
          : null,
      "m_title": titleController.text,
      "m_deadline": deadlineController.text,
      "m_reword": rewardController.text.isEmpty ? null : rewardController.text,
    };

    print('Mission Data: $missionData');

    try {
      final response = await SessionCookieManager.post(
        'http://54.180.54.31:3000/api/missions/missioncreate',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(missionData),
      );

      if (response.statusCode == 200) {
        print('Mission created successfully!');
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
      body: Padding(
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
              readOnly: true,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeSettingScreen()),
                );
                if (result != null) {
                  setState(() {
                    final DateTime date = result['selectedDate'];
                    final int hour = result['selectedHour'];
                    final int minute = result['selectedMinute'];
                    final bool isAllDay = result['isAllDay'];

                    // "종일" 선택 시와 특정 시간 선택 시 출력 형식
                    if (isAllDay) {
                      deadlineController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 종일";
                    } else {
                      deadlineController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
                    }
                  });
                }
              },
            ),
            TextField(
              controller: rewardController,
              decoration: InputDecoration(labelText: '보상'),
            ),
            CheckboxListTile(
              title: Text('내 미션'),
              value: isMyMission,
              onChanged: (value) {
                setState(() {
                  isMyMission = value!;
                  if (!isMyMission) {
                    isShareMission = false; // 내 미션 해제 시 공유도 해제
                    authenticationController.clear(); // 공유 ID 초기화
                  }
                });
              },
            ),
            if (isMyMission)
              CheckboxListTile(
                title: Text('미션 공유하기'),
                value: isShareMission,
                onChanged: (value) {
                  setState(() {
                    isShareMission = value!;
                  });
                },
              ),
            if (!isMyMission) // 내 미션 체크 안 했을 때만 표시
              TextField(
                controller: u2IdController,
                decoration: InputDecoration(labelText: '부여할 상대방 ID'),
              ),
            if (isMyMission && isShareMission) // 내 미션 && 공유 체크 시 표시
              TextField(
                controller: authenticationController,
                decoration: InputDecoration(labelText: '공유할 상대방 ID'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createMission, // 미션 생성 함수 호출
              child: Text('미션 생성'),
            ),
          ],
        ),
      ),
    );
  }
}