import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import '../Community/CommunityPostDialog.dart';

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
    try {
      final responses = await Future.wait([
        SessionTokenManager.get('http://27.113.11.48:3000/nodetest/api/comumunity_missions/printGeneralCommunityList'),
        SessionTokenManager.get('http://27.113.11.48:3000/nodetest/api/comumunity_missions/list'),
        SessionTokenManager.get('http://27.113.11.48:3000/nodetest/api/cVote'),
      ]);

      List<Map<String, dynamic>> allPosts = [];

      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body)['communities'];
        final generalPosts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['cr_num'].toString(),
          'cr_title': item['cr_title'] ?? '제목 없음',
          'cr_status': '자유게시판',
          'contents': item['contents'] ?? '내용 없음',
          'deadline': item['maded_time'] ?? '',
          'timestamp': DateTime.tryParse(item['maded_time'] ?? '') ?? DateTime.now(),
        }).toList();
        allPosts.addAll(generalPosts);
      }

      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body)['missions'];
        final recruitPosts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['cr_num'].toString(),
          'cr_title': item['cr_title'] ?? '제목 없음',
          'cr_status': '미션구인',
          'contents': item['contents'] ?? '내용 없음',
          'deadline': item['deadline'] ?? '',
          'timestamp': DateTime.tryParse(item['maded_time'] ?? '') ?? DateTime.now(),
        }).toList();
        allPosts.addAll(recruitPosts);
      }

      if (responses[2].statusCode == 200) {
        final data = json.decode(responses[2].body)['votes'];
        final votePosts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['c_number'].toString(),
          'cr_title': item['c_title'] ?? '제목 없음',
          'cr_status': '미션투표',
          'contents': item['c_contents'] ?? '내용 없음',
          'deadline': item['c_deletedate'] ?? '',
          'timestamp': DateTime.tryParse(item['c_deletedate'] ?? '') ?? DateTime.now(),
        }).toList();
        allPosts.addAll(votePosts);
      }

      allPosts.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        posts = allPosts.take(2).map((p) => {
          'cr_num': p['cr_num'].toString(),
          'cr_title': p['cr_title'].toString(),
          'cr_status': p['cr_status'].toString(),
          'contents': p['contents'].toString(),
          'deadline': p['deadline'].toString(),
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching latest posts: $e');
      setState(() => isLoading = false);
    }
  }

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