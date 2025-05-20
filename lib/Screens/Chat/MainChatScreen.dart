/*
import 'package:flutter/material.dart';
import 'GeneralRoomList.dart'; // ✅ 일반 채팅 리스트 (Token 인증 방식)
import 'OpenRoomList.dart'; // ✅ 미션 채팅 리스트 (Token 인증 방식)
import 'AddChat_screen.dart'; // 채팅방 추가 화면

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2개 탭 (일반, 미션)
  }

  @override
  void dispose() {
    _tabController.dispose(); // 해제
    super.dispose();
  }

  void _navigateToAddChat() {
    String chatType = _tabController.index == 0 ? 'general' : 'open';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(chatType: chatType), // 채팅방 생성 화면으로 이동
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
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
            Tab(text: '일반채팅', icon: Icon(Icons.chat_bubble_outline)),
            Tab(text: '미션채팅', icon: Icon(Icons.assignment)),
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
            GeneralRoomList(), // ✅ 일반 채팅방 리스트 (Token 인증 기반)
            OpenRoomList(), // ✅ 미션 채팅방 리스트 (Token 인증 기반)
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'GeneralRoomList.dart';
import 'OpenRoomList.dart';
import 'AddChat_screen.dart'; // 친구 검색 및 채팅 추가 화면

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddChatModal() {
    String chatType = _tabController.index == 0 ? 'general' : 'open';
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
      backgroundColor: Colors.lightBlue, // ✅ 배경을 흰색으로 고정
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: '일반채팅'),
            Tab(icon: Icon(Icons.assignment), text: '미션채팅'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GeneralRoomList(),
          OpenRoomList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddChatModal,
        backgroundColor: Colors.lightBlue,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}