import 'package:flutter/material.dart';

class LatestPosts extends StatelessWidget {
  final List<Map<String, String>> posts;
  final VoidCallback onNavigateToCommunity;

  LatestPosts({required this.posts, required this.onNavigateToCommunity});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최신 게시글',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 10), // 제목과 게시글 간의 여백
          ...posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // 게시글 간 여백
              child: GestureDetector(
                onTap: onNavigateToCommunity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8), // 제목과 내용 간의 여백
                      Text(
                        post['content']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}