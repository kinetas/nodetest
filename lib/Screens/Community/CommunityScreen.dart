import 'package:flutter/material.dart';
import 'MissionVotingScreen.dart';

// CommunityScreen: 커뮤니티 메인 화면
class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Tab 변경 시 상태 갱신
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능 추가
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 추가
            },
          ),
          if (_tabController.index == 0 || _tabController.index == 1) // 게시판(0) 또는 미션투표(1)에서만 + 버튼 표시
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // 새로운 항목 추가 기능
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '게시판'),
            Tab(text: '미션투표'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 게시판 내용
          ListView.builder(
            itemCount: 20, // 예시로 20개의 게시글 표시
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('게시글 제목 $index'),
                subtitle: Text('게시글 내용 $index'),
                onTap: () {
                  // 게시글 상세 보기 기능
                },
              );
            },
          ),
          MissionVotingScreen(), // 미션투표 탭은 별도의 클래스로 분리
        ],
      ),
    );
  }
}