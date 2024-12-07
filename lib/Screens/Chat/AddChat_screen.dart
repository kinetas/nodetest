import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

class AddChatScreen extends StatefulWidget {
  final String chatType; // 파라미터로 채팅방 유형 전달

  const AddChatScreen({required this.chatType, Key? key}) : super(key: key);

  @override
  _AddChatScreenState createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  final TextEditingController _u2IdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createChatRoom() async {
    const String apiUrl = 'http://54.180.54.31:3000/api/rooms';

    try {
      setState(() => _isLoading = true);

      // API 요청 데이터
      final requestBody = {
        'u2_id': _u2IdController.text, // 상대방 ID
        'roomName': _roomNameController.text.isEmpty ? null : _roomNameController.text, // 방 이름 (옵션)
        'r_type': widget.chatType, // 채팅방 유형 (전달된 chatType 사용)
      };

      // POST 요청
      final response = await SessionCookieManager.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // 성공 메시지 표시 및 이전 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방이 성공적으로 생성되었습니다!')),
          );
          Navigator.pop(context); // 이전 화면으로 돌아감
        } else {
          // 실패 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? '채팅방 생성 실패')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 생성 요청 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.chatType == 'general' ? '일반 채팅방 생성' : '미션 채팅방 생성';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _u2IdController,
              decoration: InputDecoration(
                labelText: '상대방 사용자 ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _roomNameController,
              decoration: InputDecoration(
                labelText: '채팅방 이름 (선택사항)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createChatRoom,
              child: Text('채팅방 생성'),
            ),
          ],
        ),
      ),
    );
  }
}