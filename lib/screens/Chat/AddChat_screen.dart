import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket 사용

class AddChatScreen extends StatelessWidget {
  final String chatType;
  final WebSocketChannel channel;

  AddChatScreen({required this.chatType, required this.channel});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final title = chatType == 'general' ? '일반 채팅방 추가' : '미션 채팅방 추가';

    void _createRoom() {
      final roomName = _controller.text.trim();
      if (roomName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 이름을 입력하세요.')),
        );
        return;
      }

      // WebSocket으로 방 생성 요청 전송
      final request = {
        'event': 'createRoom',
        'u1_id': '사용자1_ID', // 사용자 ID (필요에 따라 변경)
        'u2_id': '사용자2_ID', // 상대방 ID (필요에 따라 변경)
        'r_title': roomName,
      };

      channel.sink.add(request);

      // WebSocket 응답 처리
      channel.stream.listen((response) {
        final responseData = response.toString();
        if (responseData.contains('roomCreated')) {
          final roomId = responseData.split(':').last.trim(); // 생성된 방 ID 추출
          Navigator.pop(context, {'roomId': roomId, 'title': roomName}); // 결과 반환
        }
      }, onError: (error) {
        print('방 생성 오류: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성에 실패했습니다. 다시 시도하세요.')),
        );
      });
    }

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
              onPressed: _createRoom,
              child: Text('생성'),
            ),
          ],
        ),
      ),
    );
  }
}