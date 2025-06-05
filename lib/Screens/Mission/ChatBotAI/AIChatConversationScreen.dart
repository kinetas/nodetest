import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../SessionTokenManager.dart';

class AIChatConversationScreen extends StatefulWidget {
  @override
  _AIChatConversationScreenState createState() => _AIChatConversationScreenState();
}

class _AIChatConversationScreenState extends State<AIChatConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      isLoading = true;
      _controller.clear();
    });

    final token = await SessionTokenManager.getToken();
    if (token == null) {
      setState(() {
        messages.add({'sender': 'system', 'text': '❗ 토큰이 없습니다. 다시 로그인하세요.'});
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://27.113.11.48:3000/ai/recommend"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"category": text}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)); // ✅ 한글 깨짐 방지
      setState(() {
        messages.add({
          'sender': 'ai',
          'text': json["message"],
          'message': json["message"], // ✅ message 본문 따로 저장
          'title': json["title"],
          'category': json["category"],
          'source': json["source"],
        });
        isLoading = false;
      });
    } else {
      setState(() {
        messages.add({
          'sender': 'system',
          'text': '❗ 요청 실패 (${response.statusCode}): ${response.body}'
        });
        isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final isAI = message['sender'] == 'ai';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message['text'] ?? ''),
            if (isAI) ...[
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'title': message['title'],
                    'message': message['message'], // ✅ 정확한 본문 전달
                    'category': message['category'],
                    'source': message['source'],
                  });
                },
                child: Text("이 미션 추가하기"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI 미션 채팅")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "카테고리나 메시지를 입력"),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}