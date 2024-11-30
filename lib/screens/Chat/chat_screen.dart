import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'AddChat_screen.dart';
import 'NormalChatList.dart';
import 'MissionChatList.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        actions: [
          // "+" 버튼을 눌렀을 때 실행
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddChatScreen(
                    chatType: _tabController.index == 0 ? 'general' : 'mission', // 현재 탭에 따라 타입 설정
                    channel: WebSocketChannel.connect(
                      Uri.parse('ws://54.180.54.31:3000'), // WebSocket 연결
                    ),
                  ),
                ),
              );
            },
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
          NormalChatList(), // 일반 채팅 리스트
          MissionChatList(), // 미션 채팅 리스트
        ],
      ),
    );
  }
}