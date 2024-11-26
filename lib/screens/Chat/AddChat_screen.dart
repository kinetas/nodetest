import 'package:flutter/material.dart';

class AddChatScreen extends StatelessWidget {
  final String chatType;

  AddChatScreen({required this.chatType});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final title = chatType == 'general' ? '일반 채팅방 추가' : '미션 채팅방 추가';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '채팅방 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text); // 입력값 반환
              },
              child: Text('생성'),
            ),
          ],
        ),
      ),
    );
  }
}