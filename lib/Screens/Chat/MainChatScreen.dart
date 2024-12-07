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
    // 현재 선택된 탭에 따라 채팅 타입 설정
    String chatType = _tabController.index == 0 ? 'general' : 'open'; // 'general' 또는 'open'
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(chatType: chatType), // AddChatScreen에 chatType 전달
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // + 버튼
            onPressed: _navigateToAddChat, // AddChat으로 이동
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '일반채팅'),
            Tab(text: '미션채팅'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GeneralRoomList(), // 일반 채팅 리스트 화면
          OpenRoomList(), // 미션 채팅 리스트 화면
        ],
      ),
    );
  }
}