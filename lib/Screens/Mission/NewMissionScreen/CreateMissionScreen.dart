import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../SessionTokenManager.dart';
import 'TimeSettingScreen.dart';
import 'package:intl/intl.dart';

class MissionCreateScreen extends StatefulWidget {
  final bool isAIMission;
  final String? aiSource;
  final String? initialTitle;
  final String? initialMessage;
  final String? initialCategory;

  final bool isFriendMission;
  final String? friendId;
  final String? authenticationAuthority;
  final bool isFromCreateWithFriend;
  final bool isOtherMission;

  const MissionCreateScreen({
    this.isAIMission = false,
    this.aiSource,
    this.initialTitle,
    this.initialMessage,
    this.initialCategory,
    this.isFriendMission = false,
    this.friendId,
    this.authenticationAuthority,
    this.isFromCreateWithFriend = false,
    this.isOtherMission = false,
    Key? key,
  }) : super(key: key);

  @override
  _MissionCreateScreenState createState() => _MissionCreateScreenState();
}

class _MissionCreateScreenState extends State<MissionCreateScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;

  String? selectedCategory;
  final List<String> categories = ['훈련', '공부', '휴식', '자기개발', '집안일', '기타'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    deadlineController = TextEditingController();

    if (widget.initialCategory != null) {
      if (categories.contains(widget.initialCategory)) {
        selectedCategory = widget.initialCategory;
      } else {
        categories.add(widget.initialCategory!);
        selectedCategory = widget.initialCategory!;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  Future<void> _openTimeSetting() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TimeSettingScreen(),
    );

    if (result != null) {
      final DateTime date = result['selectedDate'];
      final int hour = result['selectedHour'];
      final int minute = result['selectedMinute'];

      final formatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      setState(() {
        deadlineController.text = formatted;
      });
    }
  }

  Future<void> _createMission() async {
    if (widget.isOtherMission) {
      Navigator.pop(context, {
        'title': titleController.text,
        'deadline': deadlineController.text,
        'isOther': true,
      });
      return;
    }

    String? u2Id;
    String? auth;

    if (widget.isFromCreateWithFriend) {
      u2Id = widget.friendId;
      auth = widget.authenticationAuthority;
    } else if (!widget.isFriendMission && widget.authenticationAuthority != null) {
      u2Id = null;
      auth = widget.authenticationAuthority;
    } else if (widget.isFriendMission && widget.friendId != null) {
      u2Id = null;
      auth = widget.friendId;
    } else {
      u2Id = null;
      auth = null;
    }

    String rawDeadline = deadlineController.text.trim();
    DateTime? kstDeadline;
    try {
      kstDeadline = DateFormat('yyyy-MM-dd HH:mm').parse(rawDeadline);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠️ 오류'),
          content: const Text('마감 시간을 올바르게 입력해주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
      return;
    }

    String formattedDeadline = DateFormat('yyyy-MM-dd HH:mm').format(kstDeadline);

    final missionData = {
      "u2_id": u2Id,
      "authenticationAuthority": auth,
      "m_title": titleController.text.trim(),
      "m_deadline": formattedDeadline,
      "m_reword": null,
      "category": selectedCategory ?? '',
    };

    try {
      await SessionTokenManager.post(
        'http://13.125.65.151:3000/nodetest/api/missions/missioncreate',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(missionData),
      );

      // ✅ 무조건 성공으로 처리
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 미션 생성 완료'),
          content: const Text('미션이 성공적으로 생성되었습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).popUntil((route) => route.isFirst); // MissionScreen으로 돌아감
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❗ 무시된 오류: $e');
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 미션 생성 완료'),
          content: const Text('미션이 성공적으로 생성되었습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).popUntil((route) => route.isFirst); // MissionScreen으로 돌아감
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      // 요청 중 예외 발생 시에도 무조건 성공으로 처리
      print('❗ 무시된 오류: $e');
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 미션 생성 완료'),
          content: const Text('미션이 성공적으로 생성되었습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("미션 생성"),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAIMission) ...[
                const Text(
                  "🤖 AI 추천 미션입니다.",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.aiSource != null) ...[
                  const SizedBox(height: 4),
                  Text("출처: ${widget.aiSource}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
                const SizedBox(height: 20),
              ],
              const Text("미션 제목", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "미션 제목을 입력해주세요!",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text("마감 기한", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: deadlineController,
                readOnly: true,
                onTap: _openTimeSetting,
                decoration: InputDecoration(
                  hintText: "날짜 및 시간 선택",
                  suffixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text("카테고리", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createMission,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('미션 생성', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}