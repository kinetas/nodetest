/*
import 'package:flutter/material.dart';
import 'CommunityVoteList.dart';
import 'CommunityPostList.dart'; // CommunityPostList 클래스를 import
import 'AddPost.dart'; // AddPost 화면 import
import 'AddVote.dart'; // AddVote 화면 import

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

  void _onAddButtonPressed() {
    // 현재 탭에 따라 다른 화면으로 이동
    if (_tabController.index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPost()), // 게시판 탭 -> AddPost 화면
      );
    } else if (_tabController.index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddVote()), // 미션투표 탭 -> AddVote 화면
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '커뮤니티',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.lightBlue[400],
        actions: [
          if (_tabController.index == 0 || _tabController.index == 1) // 게시판(0) 또는 미션투표(1)에서만 + 버튼 표시
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _onAddButtonPressed, // + 버튼 클릭 시 동작
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '게시판'),
            Tab(text: '미션투표'),
          ],
        ),
        elevation: 0, // 그림자 제거로 깔끔한 디자인
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: TabBarView(
          controller: _tabController,
          children: [
            CommunityPostList(), // CommunityPostList 클래스를 게시판 탭으로 설정
            CommunityVoteList(), // 미션투표 탭은 별도의 클래스로 분리
          ],
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'CommunityVoteList.dart';
import 'CommunityPostList.dart';
import 'AddPost.dart';
import 'AddVote.dart';

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
      setState(() {}); // 탭 변경 시 버튼 조건 반영
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAddButtonPressed() {
    if (_tabController.index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddPost()));
    } else if (_tabController.index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddVote()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        elevation: 2,
        title: const Text(
          '커뮤니티',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _onAddButtonPressed,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(36), // 탭 높이 축소
          child: Container(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '게시판'),
                Tab(text: '미션투표'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CommunityPostList(),
          CommunityVoteList(),
        ],
      ),
    );
  }
}