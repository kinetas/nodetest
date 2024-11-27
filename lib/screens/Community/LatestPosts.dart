import 'package:flutter/material.dart';

class LatestPosts extends StatelessWidget {
  final List<Map<String, String>> posts;
  final VoidCallback onNavigateToCommunity;

  LatestPosts({required this.posts, required this.onNavigateToCommunity});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onNavigateToCommunity,
          child: Text(
            '최신 게시글',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(posts[index]['title'] ?? '제목 없음'),
              subtitle: Text(posts[index]['content'] ?? '내용 없음'),
            );
          },
        ),
      ],
    );
  }
}