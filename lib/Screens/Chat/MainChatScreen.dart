import 'package:flutter/material.dart';
import 'GeneralRoomList.dart'; // 일반 채팅 리스트
import 'OpenRoomList.dart'; // 미션 채팅 리스트
import 'AddChat_screen.dart'; // AddChat 화면

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 두 개의 탭
  }

  @override
  void dispose() {
    _tabController.dispose(); // 탭 컨트롤러 해제
    super.dispose();
  }

  void _navigateToAddChat() {
    String chatType = _tabController.index == 0 ? 'general' : 'open'; // 'general' 또는 'open'
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(chatType: chatType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white), // + 버튼
            onPressed: _navigateToAddChat,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: '일반채팅',
              icon: Icon(Icons.chat_bubble_outline),
            ),
            Tab(
              text: '미션채팅',
              icon: Icon(Icons.assignment),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            GeneralRoomList(), // 일반 채팅 리스트 화면
            OpenRoomList(), // 미션 채팅 리스트 화면
          ],
        ),
      ),
    );
  }
}