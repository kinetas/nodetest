/*
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

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
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 게시글 리스트를 가져와 상위 두 개만 선택하고 Map<String, String>으로 변환
        final missions = List<Map<String, dynamic>>.from(data['missions'] ?? []);
        setState(() {
          posts = missions
              .take(2)
              .map((mission) => {
            'title': mission['cr_title']?.toString() ?? '제목 없음',
            'content': mission['content']?.toString() ?? '내용 없음',
          })
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to load latest posts: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching latest posts: $e');
      setState(() {
        isLoading = false;
      });
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
          SizedBox(height: 10), // 제목과 게시글 간의 여백
          ...posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // 게시글 간 여백
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
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class LatestPosts extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  const LatestPosts({required this.onNavigateToCommunity});

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
    final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list';

    try {
      final response = await SessionTokenManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final missions = List<Map<String, dynamic>>.from(data['missions'] ?? []);

        setState(() {
          posts = missions.take(2).map((mission) {
            return {
              'title': mission['cr_title']?.toString() ?? '제목 없음',
              'content': mission['content']?.toString() ?? '내용 없음',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load latest posts: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching latest posts: $e');
      setState(() {
        isLoading = false;
      });
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
          // 제목 + more 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최신 게시글',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              TextButton(
                onPressed: widget.onNavigateToCommunity,
                child: Text(
                  'more >',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // 게시글이 없을 때
          if (posts.isEmpty)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 100),
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
              alignment: Alignment.center,
              child: Text(
                '최신 게시글이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

          // 게시글 리스트 렌더링
          ...posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: widget.onNavigateToCommunity,
                child: Container(
                  width: double.infinity, // ✅ 좌우 길이 통일
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
                    crossAxisAlignment: CrossAxisAlignment.start, // ✅ 좌측 정렬
                    children: [
                      Text(
                        post['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        post['content']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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