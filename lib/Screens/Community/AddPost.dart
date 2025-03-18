import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';
import '../Mission/TimeSettingScreen.dart'; // TimeSettingScreen import

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _deadline; // 마감 시간

  // POST 요청 함수
  Future<void> _createPost() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/create';
    final body = json.encode({
      "cr_title": _titleController.text,
      "contents": _contentController.text,
      "deadline": _deadline,
    });

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 성공적으로 생성되었습니다!')),
        );
        Navigator.pop(context); // 이전 화면으로 돌아가기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 입력값 검증 및 생성
  void _onCreatePressed() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목을 입력하세요.')),
      );
      return;
    }
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('미션 내용을 입력하세요.')),
      );
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('마감 시간을 설정하세요.')),
      );
      return;
    }
    _createPost();
  }

  // TimeSettingScreen 호출
  void _selectDeadline() async {
    final selectedDeadline = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSettingScreen()),
    );
    if (selectedDeadline != null) {
      setState(() {
        // TimeSettingScreen에서 반환된 데이터를 ISO 8601 포맷으로 변환
        DateTime date = selectedDeadline['selectedDate'];
        int hour = selectedDeadline['selectedHour'];
        int minute = selectedDeadline['selectedMinute'];
        _deadline = DateTime(date.year, date.month, date.day, hour, minute).toUtc().toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 생성'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(color: Colors.lightBlue[800]),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue[300]!, width: 2),
                ),
              ),
              style: TextStyle(fontSize: 20),
              maxLength: 100,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                hintText: '어떤 미션을 수행하고 싶은지 자세히 설명해주세요!',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.lightBlue[800]),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue[300]!, width: 2),
                ),
              ),
              maxLines: 5,
              maxLength: 500, // 500자 제한
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadline == null ? '마감 시간을 설정하세요.' : '마감 시간: $_deadline',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDeadline,
                  child: Text('마감 시간 설정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[300],
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _onCreatePressed,
              child: Text('생성', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[300],
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}