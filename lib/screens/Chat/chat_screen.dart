import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 추가
import 'AddChat_screen.dart';
import 'ChatRoomScreen.dart';
import 'ChatProvider.dart'; // ChatProvider 추가

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

  void _openAddChatPopup(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentTab = _tabController.index;
    final chatType = currentTab == 0 ? 'general' : 'mission';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(chatType: chatType),
      ),
    );

    if (result != null) {
      final newChat = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': result,
        'lastMessage': '새 채팅방 생성됨',
        'time': '방금',
      };

      if (chatType == 'general') {
        chatProvider.addGeneralChat(newChat);
      } else {
        chatProvider.addMissionChat(newChat);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chatId: newChat['id']),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openAddChatPopup(context),
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
          ChatList(chatList: chatProvider.generalChatList),
          ChatList(chatList: chatProvider.missionChatList),
        ],
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  final List<Map<String, dynamic>> chatList;

  ChatList({required this.chatList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat['title']![0]),
          ),
          title: Text(chat['title'] ?? ''),
          subtitle: Text(chat['lastMessage'] ?? ''),
          trailing: Text(chat['time'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(chatId: chat['id']),
              ),
            );
          },
        );
      },
    );
  }
}