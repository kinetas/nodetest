import 'package:flutter/material.dart';
import '../../SessionCookieManager.dart';
import 'dart:convert';

class MissionCreateScreen extends StatefulWidget {
  final bool isAIMission;
  final String? aiSource;
  final String? initialTitle;
  final String? initialMessage;
  final String? initialCategory;

  const MissionCreateScreen({
    this.isAIMission = false,
    this.aiSource,
    this.initialTitle,
    this.initialMessage,
    this.initialCategory,
    Key? key,
  }) : super(key: key);

  @override
  _MissionCreateScreenState createState() => _MissionCreateScreenState();
}

class _MissionCreateScreenState extends State<MissionCreateScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController rewardController;
  late TextEditingController u2IdController;
  late TextEditingController authenticationController;

  bool isMyMission = false;
  bool isShareMission = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    deadlineController = TextEditingController();
    rewardController = TextEditingController();
    u2IdController = TextEditingController();
    authenticationController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    rewardController.dispose();
    u2IdController.dispose();
    authenticationController.dispose();
    super.dispose();
  }

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
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('미션 생성에 실패했습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("미션 생성")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAIMission) ...[
                Text(
                  "🤖 이 미션은 AI가 추천한 미션입니다.",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.aiSource != null) ...[
                  SizedBox(height: 4),
                  Text(
                    "출처: ${widget.aiSource}",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
                SizedBox(height: 16),
              ],
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '미션 제목'),
              ),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(labelText: '마감 기한 (yyyy-mm-dd)'),
              ),
              TextField(
                controller: rewardController,
                decoration: InputDecoration(labelText: '보상 (선택 사항)'),
              ),
              if (!isMyMission)
                TextField(
                  controller: u2IdController,
                  decoration: InputDecoration(labelText: '상대방 ID'),
                ),
              if (isMyMission && isShareMission)
                TextField(
                  controller: authenticationController,
                  decoration: InputDecoration(labelText: '인증 권한자 ID'),
                ),
              SwitchListTile(
                title: Text('내 미션으로 만들기'),
                value: isMyMission,
                onChanged: (value) {
                  setState(() {
                    isMyMission = value;
                    if (!value) isShareMission = false;
                  });
                },
              ),
              if (isMyMission)
                SwitchListTile(
                  title: Text('인증 권한자 설정 (공유 미션)'),
                  value: isShareMission,
                  onChanged: (value) {
                    setState(() {
                      isShareMission = value;
                    });
                  },
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createMission,
                  child: Text('미션 생성'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}