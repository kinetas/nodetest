import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

class AddVote extends StatefulWidget {
  @override
  _AddVoteState createState() => _AddVoteState();
}

class _AddVoteState extends State<AddVote> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool isLoading = false;

  // POST 요청 함수
  Future<void> createVote() async {
    final url = 'http://27.113.11.48:3000/api/cVote/create';
    final body = json.encode({
      "c_title": _titleController.text,
      "c_contents": _contentController.text,
    });

    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      setState(() {
        isLoading = false; // 로딩 상태 비활성화
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표가 성공적으로 생성되었습니다!')),
        );
        Navigator.pop(context); // 이전 화면으로 돌아가기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표 생성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false; // 로딩 상태 비활성화
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 유효성 검증 및 생성 버튼 동작
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
        title: Text(
          '투표 생성',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue[400],
        elevation: 0,
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
              maxLength: 100, // 최대 100자
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
              maxLines: 5, // 여러 줄 입력 가능
              maxLength: 500, // 최대 500자
            ),
            Spacer(),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(
                '생성',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
                minimumSize: Size(double.infinity, 50), // 버튼 크기
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