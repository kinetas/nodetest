import 'package:flutter/material.dart';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저
import 'dart:convert';

class DeleteChatDialog extends StatelessWidget {
  final String u2Id;

  const DeleteChatDialog({required this.u2Id, Key? key}) : super(key: key);

  Future<void> _deleteChat(BuildContext context) async {
    final String apiUrl = 'http://27.113.11.48:3000/api/rooms/$u2Id';

    try {
      final response = await SessionCookieManager.delete(apiUrl);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // 삭제 성공
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방이 성공적으로 삭제되었습니다.')),
          );
          Navigator.pop(context, true); // true 값으로 팝업 닫기
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? '삭제 실패')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 요청 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('채팅방 삭제'),
      content: Text('채팅방을 정말 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // 팝업 닫기
          child: Text('아니오'),
        ),
        TextButton(
          onPressed: () => _deleteChat(context), // 삭제 요청
          child: Text(
            '예',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}