/*
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 수정

class AddChatScreen extends StatefulWidget {
  final String chatType;

  const AddChatScreen({required this.chatType, Key? key}) : super(key: key);

  @override
  _AddChatScreenState createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  final TextEditingController _u2IdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createChatRoom() async {
    const String apiUrl = 'http://27.113.11.48:3000/api/rooms';

    try {
      setState(() => _isLoading = true);

      final requestBody = {
        'u2_id': _u2IdController.text,
        'roomName': _roomNameController.text.isEmpty
            ? '${_u2IdController.text}-${widget.chatType}'
            : _roomNameController.text,
        'r_type': widget.chatType,
      };

      final response = await SessionTokenManager.post(
        apiUrl,
        body: jsonEncode(requestBody),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['message'] == "방이 성공적으로 추가되었습니다.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방이 성공적으로 생성되었습니다!')),
          );
          Navigator.pop(context);
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
        title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              _buildTextField(_u2IdController, '상대방 사용자 ID'),
              SizedBox(height: 16),
              _buildTextField(_roomNameController, '채팅방 이름 (선택사항)'),
              SizedBox(height: 32),
              _isLoading
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue))
                  : ElevatedButton(
                onPressed: _createChatRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('채팅방 생성', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
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
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class AddChatScreen extends StatefulWidget {
  final String chatType;

  const AddChatScreen({required this.chatType, Key? key}) : super(key: key);

  @override
  _AddChatScreenState createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  final TextEditingController _u2IdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createChatRoom() async {
    const String apiUrl = 'http://27.113.11.48:3000/api/rooms';

    try {
      setState(() => _isLoading = true);

      final requestBody = {
        'u2_id': _u2IdController.text.trim(),
        'roomName': _roomNameController.text.trim().isEmpty
            ? '${_u2IdController.text}-${widget.chatType}'
            : _roomNameController.text.trim(),
        'r_type': widget.chatType,
      };

      final response = await SessionTokenManager.post(
        apiUrl,
        body: jsonEncode(requestBody),
      );

      setState(() => _isLoading = false);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == "방이 성공적으로 추가되었습니다.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 채팅방이 생성되었습니다')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 실패: ${responseData['message']}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❗ 네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
    widget.chatType == 'general' ? '일반 채팅방 생성' : '미션 채팅방 생성';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(_u2IdController, '상대방 사용자 ID'),
            const SizedBox(height: 20),
            _buildTextField(_roomNameController, '채팅방 이름 (선택사항)'),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : ElevatedButton(
              onPressed: _createChatRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '채팅방 생성',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}