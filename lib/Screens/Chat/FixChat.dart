import 'package:flutter/material.dart';

class FixChat extends StatelessWidget {
  final String u2Id;
  final String rType;

  FixChat({required this.u2Id, required this.rType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Fix Chat"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('상대방 아이디: $u2Id'),
          Text('방 타입: $rType'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 방 이름 수정 로직 추가
              print("방 이름 수정: u2Id=$u2Id, rType=$rType");
              Navigator.pop(context); // 팝업 닫기
            },
            child: Text('방 이름 수정'),
          ),
          ElevatedButton(
            onPressed: () {
              // 방 삭제 로직 추가
              print("방 삭제: u2Id=$u2Id, rType=$rType");
              Navigator.pop(context); // 팝업 닫기
            },
            child: Text('방 삭제'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 팝업 닫기
          },
          child: Text('닫기'),
        ),
      ],
    );
  }
}