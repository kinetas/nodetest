import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> posts = [
    {'title': '자유 제목', 'content': '자유 내용 첫 줄', 'category': '자유게시판', 'time': 'now', 'likes': 5, 'timestamp': DateTime.now().subtract(Duration(minutes: 5))},
    {'title': '자유+이미지', 'content': '이미지 있는 글', 'category': '자유게시판', 'time': '1:23', 'likes': 2, 'timestamp': DateTime.now().subtract(Duration(hours: 1))},
    {'title': '자유+댓글', 'content': '댓글 포함 내용', 'category': '자유게시판', 'time': '12:23', 'likes': 3, 'timestamp': DateTime.now().subtract(Duration(hours: 3))},
    {'title': '미션 같이 할 사람~', 'content': '같이 하실?', 'category': '미션구인', 'time': '1 day', 'likes': 8, 'timestamp': DateTime.now().subtract(Duration(days: 1)), 'people': '00'},
    {'title': '이런 미션 했습니다.', 'content': '미션 후기', 'category': '미션투표', 'time': '1 day', 'likes': 6, 'timestamp': DateTime.now().subtract(Duration(days: 1)), 'vote': {'agree': '00', 'disagree': '00'}},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  void _onAddButtonPressed() {
    final label = _tabTitles[_tabController.index];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label 글 작성 화면으로 이동')));
  }

  Widget _buildPostTile(Map<String, dynamic> post) {
    Widget? extra;
    if (post['category'] == '미션구인') {
      extra = Row(children: [Icon(Icons.people_outline, size: 14), Text(' ${post['people']}', style: TextStyle(fontSize: 12))]);
    } else if (post['category'] == '미션투표') {
      extra = Row(children: [Text('찬성 ${post['vote']['agree']}', style: TextStyle(fontSize: 12, color: Colors.cyan)), SizedBox(width: 8), Text('반대 ${post['vote']['disagree']}', style: TextStyle(fontSize: 12, color: Colors.red))]);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post['content']),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('조회 00  |  추천 ${post['likes']}  |  ${post['category']}  |', style: TextStyle(fontSize: 12)),
              if (extra != null) extra,
              Spacer(),
              Text(post['time'], style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
      onTap: () {
        if (post['category'] == '미션구인') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MissionRecruitDetailScreen()));
        } else if (post['category'] == '자유게시판') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => FreeBoardDetailScreen()));
        } else if (post['category'] == '미션투표') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MissionVoteDetailScreen()));
        }
      },
    );
  }

  Widget _buildFilteredTab(String category) {
    List<Map<String, dynamic>> filteredPosts;

    if (category == '전체글') {
      filteredPosts = [...posts];
    } else if (category == '인기글') {
      filteredPosts = [...posts]..sort((a, b) => b['likes'].compareTo(a['likes']));
    } else {
      filteredPosts = posts.where((p) => p['category'] == category).toList();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredPosts.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
      itemBuilder: (context, index) => _buildPostTile(filteredPosts[index]),
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
          title: const Text('커뮤니티', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('검색 기능 준비 중'))),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.lightBlue,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.lightBlue,
                indicatorWeight: 2,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabTitles.map((title) => _buildFilteredTab(title)).toList(),
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