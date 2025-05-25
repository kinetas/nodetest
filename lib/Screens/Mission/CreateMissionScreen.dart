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
        'http://27.113.11.48:3000/nodetest/api/missions/missioncreate',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(missionData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Mission created successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('미션이 성공적으로 생성되었습니다!')),
          );
          Navigator.pop(context); // 이전 화면으로 이동
        } else {
          print('Mission creation failed: ${responseData['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('미션 생성 실패: ${responseData['message'] ?? '알 수 없는 오류'}'),
            ),
          );
        }
      } else {
        print('Failed to create mission: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류로 미션 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (error) {
      print('Error creating mission: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 생성'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextField(titleController, '미션 제목'),
              _buildReadOnlyTextField(deadlineController, '미션 기한', context),
              _buildTextField(rewardController, '보상'),
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
                activeColor: Colors.lightBlue,
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
                  activeColor: Colors.lightBlue,
                ),
              if (!isMyMission)
                _buildTextField(u2IdController, '부여할 상대방 ID'),
              if (isMyMission && isShareMission)
                _buildTextField(authenticationController, '공유할 상대방 ID'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createMission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '미션 생성',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller, String labelText, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
        ),
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

              if (isAllDay) {
                controller.text =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 종일";
              } else {
                controller.text =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
              }
            });
          }
        },
      ),
    );
  }
}