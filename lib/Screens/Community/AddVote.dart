import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ http 제거, 토큰 매니저만 사용

class AddVote extends StatefulWidget {
  @override
  _AddVoteState createState() => _AddVoteState();
}

class _AddVoteState extends State<AddVote> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool isLoading = false;

  Future<void> createVote() async {
    final url = 'http://27.113.11.48:3000/api/cVote/create';

    final body = json.encode({
      "c_title": _titleController.text,
      "c_contents": _contentController.text,
    });

    print('📤 투표 생성 요청: $body');

    setState(() => isLoading = true);

    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 응답 상태 코드: ${response.statusCode}');
      print('📥 응답 바디: ${response.body}');

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표가 성공적으로 생성되었습니다!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표 생성에 실패했습니다. 다시 시도해주세요.')),
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

  void onSubmit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해야 합니다.')),
      );
      return;
    }
    createVote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('투표 생성', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]))
          : Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '투표 제목',
                labelStyle: TextStyle(color: Colors.lightBlue[800]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue[400]!, width: 2),
                ),
              ),
              style: TextStyle(fontSize: 18),
              maxLength: 100,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '투표 내용',
                hintText: '투표 내용을 입력하세요.',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.lightBlue[800]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue[400]!, width: 2),
                ),
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text('생성', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}