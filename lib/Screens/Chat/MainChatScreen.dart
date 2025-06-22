import 'package:flutter/material.dart';
import 'GeneralRoomList.dart';
import 'OpenRoomList.dart';
import 'AddChat_screen.dart';

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
    final Color pointColor = Colors.lightBlue;
    final Color backgroundColor = Colors.white;
    final Color textColor = Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 1,
        title: Text(
          '채팅',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: pointColor,
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: pointColor,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '일반채팅'),
                Tab(text: '미션채팅'),
              ],
            ),
          ),
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
        backgroundColor: pointColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}