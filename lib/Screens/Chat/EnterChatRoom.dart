import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 실제 프로젝트에 맞는 경로로 수정
import 'ChatRoomScreen.dart'; // ChatRoomScreen.dart 파일 경로에 맞게 수정

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
      final url = 'http://54.180.54.31:3000/api/rooms/enter';
      final body = {
        'r_id': widget.roomData['r_id'], // 전달받은 room 데이터에서 r_id 가져오기
        'u2_id': widget.roomData['u2_id'], // 전달받은 room 데이터에서 u2_id 가져오기
      };

      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('방 입장 성공');
        // ChatRoomScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomData: widget.roomData, // room 데이터 전달
            ),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        // 에러 처리
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('오류'),
            content: Text('방 입장에 실패했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error during room entry: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('네트워크 연결을 확인해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Center(
        child: Text('채팅방 입장 중...'),
      ),
    );
  }
}