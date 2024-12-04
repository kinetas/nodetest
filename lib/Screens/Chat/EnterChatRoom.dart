import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저 추가
import 'ChatRoomScreen.dart';

class EnterChatroom extends StatelessWidget {
  final String rId; // 방 ID (r_id)
  final String u2Id; // 친구 ID (u2_id)

  const EnterChatroom({
    required this.rId,
    required this.u2Id,
    Key? key,
  }) : super(key: key);

  Future<void> _enterRoom(BuildContext context) async {
    const String apiUrl = 'http://54.180.54.31:3000/api/rooms/enter';

    try {
      // 세션 쿠키 매니저를 사용한 POST 요청
      final response = await SessionCookieManager.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'r_id': rId, 'u2_id': u2Id}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['message'] == "방에 성공적으로 입장했습니다.") {
          final roomData = responseData['room'];

          // 방 입장 성공 시 ChatRoomScreen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatId: roomData['r_id'], // 방 ID
                chatTitle: roomData['i_title'] ?? '제목 없음', // 방 제목
                userId: roomData['u1_id'], // 현재 사용자 ID
                otherUserId: roomData['u2_id'], // 상대방 ID
              ),
            ),
          );
        } else {
          _showErrorDialog(context, responseData['message'] ?? '방 입장 실패');
        }
      } else {
        _showErrorDialog(context, '방 입장 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(context, '네트워크 오류: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterRoom(context); // 방 입장 시도
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}