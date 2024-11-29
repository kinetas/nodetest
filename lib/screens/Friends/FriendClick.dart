import 'package:flutter/material.dart';

class FriendClick extends StatelessWidget {
  final String friendId;

  const FriendClick({required this.friendId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // 팝업 외부를 클릭하면 닫힘
      },
      child: Material(
        color: Colors.black.withOpacity(0.5), // 뒤 화면 흐리게
        child: Center(
          child: Container(
            width: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(friendId[0]), // ID의 첫 글자 표시
                ),
                SizedBox(height: 16),
                Text(
                  '친구 ID: $friendId',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chat, size: 32, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('채팅 기능 구현 예정')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.assignment, size: 32, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('미션 생성 기능 구현 예정')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}