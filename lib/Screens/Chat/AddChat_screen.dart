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
        'roomName': _roomNameController.text.isEmpty
            ? '${_u2IdController.text}-${widget.chatType}' // 기본 방 이름 설정
            : _roomNameController.text, // 입력된 방 이름 사용
        'r_type': widget.chatType, // 채팅방 유형
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

        if (responseData['message'] == "방이 성공적으로 추가되었습니다.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방이 성공적으로 생성되었습니다!')),
          );
          Navigator.pop(context); // 이전 화면으로 돌아감
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방 생성 실패: ${responseData['message']}')),
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
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                controller: _u2IdController,
                labelText: '상대방 사용자 ID',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _roomNameController,
                labelText: '채팅방 이름 (선택사항)',
              ),
              SizedBox(height: 32),
              _isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              )
                  : ElevatedButton(
                onPressed: _createChatRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // 버튼 배경색
                  foregroundColor: Colors.white, // 버튼 텍스트 색상
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '채팅방 생성',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}