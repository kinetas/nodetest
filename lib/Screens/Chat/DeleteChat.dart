import 'package:flutter/material.dart';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 변경
import 'dart:convert';

class DeleteChatDialog extends StatelessWidget {
  final String u2Id;

  const DeleteChatDialog({required this.u2Id, Key? key}) : super(key: key);

  Future<void> _deleteChat(BuildContext context) async {
    final String apiUrl = 'http://27.113.11.48:3000/api/rooms/$u2Id';

    try {
      print('📤 [DELETE] 요청: $apiUrl');
      final response = await SessionTokenManager.delete(apiUrl);

      print('📥 [응답] ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('채팅방이 성공적으로 삭제되었습니다.')),
          );
          Navigator.pop(context, true); // 성공 시 true 반환
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
      print('❌ 네트워크 오류: $e');
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
          onPressed: () => Navigator.pop(context, false), // 취소 시 false 반환
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