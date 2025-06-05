import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import 'CommunityPostDialog.dart'; // 플로팅 카드 상세 뷰 위젯 임포트!

class LatestPosts extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  const LatestPosts({required this.onNavigateToCommunity, Key? key}) : super(key: key);

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
              'cr_num': mission['cr_num']?.toString() ?? '',
              'cr_title': mission['cr_title']?.toString() ?? '제목 없음',
              'cr_status': mission['cr_status']?.toString() ?? '',
              'contents': mission['contents']?.toString() ?? '내용 없음',
              'deadline': mission['deadline']?.toString() ?? '',
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

  // 날짜 포맷 변환 (2025-05-30T11:55:00.000Z -> 2025년 5월 30일 20시 55분)
  String formatDeadline(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분';
    } catch (e) {
      return isoString;
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

          // 게시글 리스트
          ...posts.map((post) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  // 게시글 클릭 시 플로팅 상세카드 다이얼로그로
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CommunityPostDialog(
                      crNum: post['cr_num'] ?? '',
                      crTitle: post['cr_title'] ?? '',
                      crStatus: post['cr_status'] ?? '',
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
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
                        post['cr_title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      // 마감일 표기
                      if ((post['deadline'] ?? '').isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.lightBlue, size: 16),
                            SizedBox(width: 4),
                            Text(
                              formatDeadline(post['deadline']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.lightBlue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      if ((post['deadline'] ?? '').isNotEmpty)
                        SizedBox(height: 8),
                      Text(
                        post['contents'] ?? '',
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
