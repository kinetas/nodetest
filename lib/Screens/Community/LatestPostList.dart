import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ SessionTokenManager로 전환

class LatestPosts extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  LatestPosts({required this.onNavigateToCommunity});

  @override
  _LatestPostsState createState() => _LatestPostsState();
}

class _LatestPostsState extends State<LatestPosts> {
  List<Map<String, String>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestPosts();
  }

  Future<void> fetchLatestPosts() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/list';

    try {
      final response = await SessionTokenManager.get(url); // ✅ 수정된 부분

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final missions = List<Map<String, dynamic>>.from(data['missions'] ?? []);
        setState(() {
          posts = missions
              .take(2)
              .map((mission) => {
            'title': mission['cr_title']?.toString() ?? '제목 없음',
            'content': mission['contents']?.toString() ?? '내용 없음', // ✅ 'contents'로 수정
          })
              .toList();
          isLoading = false;
        });
      } else {
        print('📛 최신 게시글 로딩 실패: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('⚠️ 최신 게시글 요청 중 오류: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue[700]!;

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
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
          SizedBox(height: 10),
          ...posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: widget.onNavigateToCommunity,
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
                      SizedBox(height: 8),
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