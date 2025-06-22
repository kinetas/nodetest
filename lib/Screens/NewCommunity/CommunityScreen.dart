import 'package:flutter/material.dart';

import 'dart:convert';
import '../../SessionTokenManager.dart';
import 'CreateRecruit.dart';
import 'CreateVote.dart';
import 'CreateFree.dart';
import 'MissionRecruitDetailScreen.dart';
import 'FreeBoardDetailScreen.dart';
import 'MissionVoteDetailScreen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['전체글', '미션구인', '미션투표', '인기글', '자유게시판'];

  List<Map<String, dynamic>> posts = [];         // 자유게시판
  List<Map<String, dynamic>> recruitPosts = [];    // 미션구인
  List<Map<String, dynamic>> votePosts = [];       // 미션투표
  List<Map<String, dynamic>> popularPosts = [];    // 인기글

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchGeneralPosts(),
      fetchRecruitPosts(),
      fetchVotePosts(),
      fetchPopularPosts(),
    ]);
  }

  Future<void> fetchGeneralPosts() async {
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/comumunity_missions/printGeneralCommunityList',
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['communities'];
      setState(() {
        posts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['cr_num'],
          'title': item['cr_title'],
          'content': item['contents'],
          'category': '자유게시판',
          'time': _formatTime(item['maded_time']),
          'likes': item['recommended_num'] ?? 0,
          'hits': item['hits'] ?? 0,
          'timestamp': DateTime.tryParse(item['maded_time'] ?? '') ?? DateTime.now(),
        }).toList();
      });
    } else {
      print('❌ 자유게시판 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> fetchRecruitPosts() async {
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/comumunity_missions/list',
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['missions'];
      setState(() {
        recruitPosts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['cr_num'],
          'title': item['cr_title'],
          'content': item['contents'],
          'category': '미션구인',
          'time': _formatTime(item['maded_time']),
          'likes': item['recommended_num'] ?? 0,
          'hits': item['hits'] ?? 0,
          'people': '00',
          'timestamp': DateTime.tryParse(item['maded_time'] ?? '') ?? DateTime.now(),
        }).toList();
      });
    } else {
      print('❌ 미션구인 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> fetchVotePosts() async {
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/cVote',
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['votes'];
      setState(() {
        votePosts = data.map<Map<String, dynamic>>((item) {
          final rawTime = item['maded_time'] ?? item['vote_create_date'] ?? item['c_deletedate'];
          return {
            'c_number': item['c_number'],
            'title': item['c_title'],
            'content': item['c_contents'],
            'category': '미션투표',
            'time': _formatTime(rawTime),
            'likes': item['c_good'] ?? 0,
            'dislikes': item['c_bad'] ?? 0,
            'hits': 0,
            'timestamp': DateTime.tryParse(rawTime ?? '') ?? DateTime.now(),
          };
        }).toList();
      });
    } else {
      print('❌ 미션투표 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> fetchPopularPosts() async {
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/comumunity_missions/getpopularyityCommunityList',
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['communities'];
      setState(() {
        popularPosts = data.map<Map<String, dynamic>>((item) => {
          'cr_num': item['cr_num'],
          'title': item['cr_title'],
          'content': item['contents'],
          'category': '자유게시판',
          'time': _formatTime(item['maded_time']),
          'likes': item['recommended_num'] ?? 0,
          'hits': item['hits'] ?? 0,
          'timestamp': DateTime.tryParse(item['maded_time'] ?? '') ?? DateTime.now(),
        }).toList();
      });
    } else {
      print('❌ 인기글 불러오기 실패: ${response.statusCode}');
    }
  }

  String _formatTime(String? iso) {
    final time = DateTime.tryParse(iso ?? '');
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 0) return '방금 전';
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  Widget _buildPostTile(Map<String, dynamic> post) {
    final bool isRecruit = post['category'] == '미션구인';
    final bool isVote = post['category'] == '미션투표';

    Widget? extraInfo;
    if (isRecruit) {
      extraInfo = Row(
        children: [
          Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('${post['people']}', style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      );
    } else if (isVote) {
      extraInfo = Row(
        children: [
          Text('👍 ${post['likes']}', style: TextStyle(fontSize: 12, color: Colors.black87)),
          SizedBox(width: 8),
          Text('👎 ${post['dislikes']}', style: TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      );
    }

    return InkWell(
      onTap: () {
        if (isRecruit) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MissionRecruitDetailScreen(crNum: post['cr_num'])));
        } else if (isVote) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MissionVoteDetailScreen(cNum: post['c_number'])));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => FreeBoardDetailScreen(crNum: post['cr_num'])));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'] ?? '',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            SizedBox(height: 6),
            Text(
              post['content'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                if (!isVote)
                  Text(
                    '${post['category']} • 조회 ${post['hits']} • 추천 ${post['likes']}',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                if (extraInfo != null) ...[
                  if (!isVote) SizedBox(width: 10),
                  extraInfo,
                ],
                Spacer(),
                Text(
                  post['time'],
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                ),
              ],
            ),
            Divider(height: 20, thickness: 0.7, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredTab(String category) {
    List<Map<String, dynamic>> list;
    if (category == '전체글') {
      list = [...posts, ...recruitPosts, ...votePosts];
    } else if (category == '미션구인') {
      list = recruitPosts;
    } else if (category == '미션투표') {
      list = votePosts;
    } else if (category == '인기글') {
      list = popularPosts;
    } else {
      list = posts;
    }

    list.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, i) => _buildPostTile(list[i]),
      ),
    );
  }

  void _onAddButtonPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWriteOption('미션 구인', Icons.group, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRecruit()));
              }),
              _buildWriteOption('미션 투표', Icons.how_to_vote, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateVote()));
              }),
              _buildWriteOption('자유게시판', Icons.edit_note, () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateFree()));
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWriteOption(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue),
      title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          automaticallyImplyLeading: false, // ← 뒤로가기 버튼 제거
          title: const Text(
            '커뮤니티',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('검색 기능 준비 중')),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: Colors.lightBlue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.lightBlue,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: _tabTitles.map((t) => FittedBox(child: Tab(text: t))).toList(),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                _tabTitles.map((title) => _buildFilteredTab(title)).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddButtonPressed,
          backgroundColor: Colors.lightBlueAccent,
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
