import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import 'MissionRecruitDetailScreen.dart';
import 'FreeBoardDetailScreen.dart';
import 'MissionVoteDetailScreen.dart';

class LatestPosts extends StatefulWidget {
  final VoidCallback onNavigateToCommunity;

  const LatestPosts({required this.onNavigateToCommunity, Key? key}) : super(key: key);

  @override
  _LatestPostsState createState() => _LatestPostsState();
}

class _LatestPostsState extends State<LatestPosts> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestPosts();
  }

  Future<void> fetchLatestPosts() async {
    try {
      final response = await SessionTokenManager.get(
        'http://13.125.65.151:3000/nodetest/api/comumunity_missions/getLastTwoCommunities',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['latest'] ?? [];

        List<Map<String, dynamic>> parsedPosts = [];

        for (var item in data) {
          final type = item['type'];

          final post = {
            'type': type,
            'cr_num': item['cr_num'] ?? '',
            'title': item['cr_title'] ?? '제목 없음',
            'content': item['cr_contents'] ?? '내용 없음',
            'category': () {
              switch (type) {
                case 'vote':
                  return '미션투표';
                case 'room_mission':
                  return '미션구인';
                case 'room_general':
                  return '자유게시판';
                default:
                  return '기타';
              }
            }(),
            'time': _formatTime(item['maded_time'] ?? item['vote_create_date']),
            'likes': item['recommended_num'] ?? 0,
            'hits': item['hits'] ?? 0,
          };

          parsedPosts.add(post);
        }

        setState(() {
          posts = parsedPosts;
          isLoading = false;
        });
      } else {
        throw Exception('서버 응답 오류');
      }
    } catch (e) {
      print('❌ 최신 게시글 불러오기 실패: $e');
      setState(() => isLoading = false);
    }
  }

  String _formatTime(String? iso) {
    final time = DateTime.tryParse(iso ?? '');
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  void navigateToDetail(Map<String, dynamic> post) {
    if (post['type'] == 'vote') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionVoteDetailScreen(cNum: post['cr_num']),
        ),
      );
    } else if (post['type'] == 'room_mission') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionRecruitDetailScreen(crNum: post['cr_num']),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FreeBoardDetailScreen(crNum: post['cr_num']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최신 게시글',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: widget.onNavigateToCommunity,
                child: Text(
                  'more >',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (posts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '최신 게시글이 없습니다.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ...posts.map((post) => InkWell(
            onTap: () => navigateToDetail(post),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post['content'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${post['category']} • 조회 ${post['hits']} • 추천 ${post['likes']}',
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Text(
                          post['time'],
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}