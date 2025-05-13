import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반

class FixChat extends StatelessWidget {
  final String u2Id;
  final String rType;

  FixChat({required this.u2Id, required this.rType});

  Future<void> _renameRoom(BuildContext context) async {
    final TextEditingController _renameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('방 이름 수정'),
        content: TextField(
          controller: _renameController,
          decoration: InputDecoration(hintText: '새로운 방 이름 입력'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _renameController.text.trim();
              if (newName.isEmpty) return;

              final url = 'http://27.113.11.48:3000/api/rooms/rename';
              final body = json.encode({
                'u2_id': u2Id,
                'r_type': rType,
                'new_title': newName,
              });

              final response = await SessionTokenManager.post(url, body: body);

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('방 이름이 수정되었습니다.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('수정 실패: ${response.statusCode}')),
                );
              }
              Navigator.pop(context); // 닫기
              Navigator.pop(context); // FixChat 닫기
            },
            child: Text('수정'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(BuildContext context) async {
    final url = 'http://27.113.11.48:3000/api/rooms/delete';
    final body = json.encode({
      'u2_id': u2Id,
      'r_type': rType,
    });

    final response = await SessionTokenManager.delete(url, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방이 삭제되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${response.statusCode}')),
      );
    }
    Navigator.pop(context); // FixChat 닫기
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("채팅방 관리"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('상대방 아이디: $u2Id'),
          Text('방 타입: $rType'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _renameRoom(context),
            child: Text('방 이름 수정'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => _deleteRoom(context),
            child: Text('방 삭제'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('닫기'),
        ),
      ],
    );
  }
}