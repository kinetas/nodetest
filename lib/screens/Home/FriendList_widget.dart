import 'package:flutter/material.dart';
import 'FriendSearch_screen.dart';  // Adjust the import paths as needed
import 'AddFriend_screen.dart';    // Adjust the import paths as needed

class FriendListWidget extends StatelessWidget {
  void _navigateToFriendSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendSearchScreen()),
    );
  }

  void _navigateToAddFriend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFriendScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 친구 목록 데이터를 20개 생성
    final List<String> friends = List.generate(20, (index) => '친구 ${index + 1}');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _navigateToFriendSearch(context),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToAddFriend(context),
            ),
          ],
        ),
        Expanded( // ListView가 화면의 남은 공간을 차지하도록 설정
          child: ListView.builder(
            itemCount: friends.length, // 친구 목록의 길이
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'), // 친구 번호
                ),
                title: Text(friends[index]), // 친구 이름
                onTap: () {
                  // 친구를 선택했을 때의 동작
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${friends[index]} 선택됨')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}