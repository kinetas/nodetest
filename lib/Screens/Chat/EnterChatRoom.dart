import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 수정
import 'ChatRoomScreen.dart'; // 실제 프로젝트 경로 맞게 수정

class EnterChatRoom extends StatefulWidget {
  final Map<String, dynamic> roomData; // room 객체 전체

  EnterChatRoom({required this.roomData});

  @override
  _EnterChatRoomState createState() => _EnterChatRoomState();
}

class _EnterChatRoomState extends State<EnterChatRoom> {
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    enterChatRoom(); // 방 진입 로직 호출
  }

  Future<void> enterChatRoom() async {
    try {
      final token = await SessionTokenManager.getToken();
      final url = 'http://27.113.11.48:3000/nodetest/api/rooms/enter';
      final body = {
        'r_id': widget.roomData['r_id'], // 전달받은 room 데이터에서 r_id 가져오기
        'u2_id': widget.roomData['u2_id'], // 전달받은 room 데이터에서 u2_id 가져오기
      };

      print('📤 [방 입장 요청] $body');
      final response = await SessionTokenManager.post(
        url,
        body: json.encode(body),
      );

      print('📥 [응답 코드] ${response.statusCode}');
      print('📦 [응답 바디] ${response.body}');

      if (response.statusCode == 200) {
        print('✅ 방 입장 성공');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomData: widget.roomData, // room 데이터 전달
            ),
          ),
        );
      } else {
        print('❌ 방 입장 실패: ${response.statusCode}');
        _showErrorDialog('방 입장에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      _showErrorDialog('네트워크 연결을 확인해주세요.');
    } finally {
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : Center(child: Text('채팅방 입장 중...')),
    );
  }
}