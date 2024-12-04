import 'package:flutter/material.dart';

// 실시간 인기 글 위젯
class CommunityPopularPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('실시간 인기 글', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListTile(
          title: Text('Popular Post 1'),
          subtitle: Text('Details about popular post 1'),
        ),
        ListTile(
          title: Text('Popular Post 2'),
          subtitle: Text('Details about popular post 2'),
        ),
      ],
    );
  }
}