import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../SessionTokenManager.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _aiResponse;

  Future<void> _sendPrompt() async {
    final category = _controller.text;
    final token = await SessionTokenManager.getToken();

    if (token == null) {
      setState(() {
        _aiResponse = "❗ 로그인 토큰이 없습니다. 다시 로그인해주세요.";
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://27.113.11.48:3000/ai/recommend"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"category": category}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = {
        'title': json["title"],
        'message': json["message"],
        'category': json["category"],
        'source': json["source"],
      };
      Navigator.pop(context, result);
    } else {
      setState(() {
        _aiResponse = '''
AI 요청 실패!
상태 코드: ${response.statusCode}
응답 내용: ${response.body}
''';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI 인증 요청")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "카테고리를 입력하세요 (예: 운동, 공부 등)"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendPrompt,
              child: Text("AI에게 인증 요청"),
            ),
            if (_aiResponse != null) ...[
              SizedBox(height: 20),
              Text("AI 응답:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_aiResponse!),
            ],
          ],
        ),
      ),
    );
  }
}