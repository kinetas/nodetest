
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ http 제거
import '../Mission/TimeSettingScreen.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _deadline;
  bool isLoading = false;

  Future<void> _createPost() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/create';

    final body = json.encode({
      "cr_title": _titleController.text,
      "contents": _contentController.text,
      "deadline": _deadline,
    });

    try {
      setState(() => isLoading = true);
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        print('✅ 게시글 생성 성공: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 성공적으로 생성되었습니다!')),
        );
        Navigator.pop(context);
      } else {
        print('❌ 게시글 생성 실패: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _onCreatePressed() {
    if (_titleController.text.isEmpty) {
      _showSnackBar('제목을 입력하세요.');
      return;
    }
    if (_contentController.text.isEmpty) {
      _showSnackBar('미션 내용을 입력하세요.');
      return;
    }
    if (_deadline == null) {
      _showSnackBar('마감 시간을 설정하세요.');
      return;
    }
    _createPost();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectDeadline() async {
    final selectedDeadline = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSettingScreen()),
    );

    if (selectedDeadline != null) {
      setState(() {
        DateTime date = selectedDeadline['selectedDate'];
        int hour = selectedDeadline['selectedHour'];
        int minute = selectedDeadline['selectedMinute'];
        _deadline = DateTime(date.year, date.month, date.day, hour, minute).toUtc().toIso8601String();
        print('🕒 마감 시간 설정됨: $_deadline');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시글 생성'), backgroundColor: Colors.lightBlue[300]),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[300]))
          : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                hintText: '어떤 미션을 수행하고 싶은지 자세히 설명해주세요!',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _deadline == null ? '마감 시간을 설정하세요.' : '마감 시간: $_deadline',
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDeadline,
                  child: Text('마감 시간 설정'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[300]),
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