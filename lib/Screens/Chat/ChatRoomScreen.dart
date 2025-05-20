/*
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../SessionTokenManager.dart'; // ✅ 토큰 매니저 import
import 'ChatContent.dart';
import 'ChatPlusButton.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const ChatRoomScreen({
    required this.roomData,
    Key? key,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  bool _showPlusOptions = false;
  final GlobalKey<ChatContentState> _chatContentKey = GlobalKey<ChatContentState>();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    final token = await SessionTokenManager.getToken();
    print('🔐 JWT Token for Socket: $token');

    socket = IO.io(
      'http://27.113.11.48:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'}) // ✅ 헤더로 토큰 전달
          .build(),
    );

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u1_id': widget.roomData['u1_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
      socket.connect();
    });

    socket.on('receiveMessage', (data) {
      print('📥 Message received: $data');
      _chatContentKey.currentState?.addMessage(data);
    });

    socket.connect();
  }

  void _sendMessage() {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) return;

    final messageData = {
      'r_id': widget.roomData['r_id'],
      'u1_id': widget.roomData['u1_id'],
      'u2_id': widget.roomData['u2_id'],
      'message_contents': messageContent,
      'send_date': DateTime.now().toIso8601String(),
    };

    print('📤 Sending message: $messageData');
    socket.emit('sendMessage', messageData);
    _messageController.clear();
  }

  void _togglePlusOptions() {
    setState(() {
      _showPlusOptions = !_showPlusOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomData['r_title'] ?? '채팅방', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ChatContent(
                key: _chatContentKey,
                chatId: widget.roomData['r_id'],
                userId: widget.roomData['u1_id'],
                otherUserId: widget.roomData['u2_id'],
              ),
            ),
            if (_showPlusOptions)
              ChatPlusButton(roomData: widget.roomData),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.lightBlue),
                    onPressed: _togglePlusOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.lightBlue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../SessionTokenManager.dart';
import 'ChatContent.dart';
import 'ChatPlusButton.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const ChatRoomScreen({
    required this.roomData,
    Key? key,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  bool _showPlusOptions = false;
  final GlobalKey<ChatContentState> _chatContentKey = GlobalKey<ChatContentState>();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    final token = await SessionTokenManager.getToken();

    socket = IO.io(
      'http://27.113.11.48:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u1_id': widget.roomData['u1_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      socket.connect();
    });

    socket.on('receiveMessage', (data) {
      _chatContentKey.currentState?.addMessage(data);
    });

    socket.connect();
  }

  void _sendMessage() {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty) return;

    final messageData = {
      'r_id': widget.roomData['r_id'],
      'u1_id': widget.roomData['u1_id'],
      'u2_id': widget.roomData['u2_id'],
      'message_contents': messageContent,
      'send_date': DateTime.now().toIso8601String(),
    };

    socket.emit('sendMessage', messageData);
    _messageController.clear();
  }

  void _togglePlusOptions() {
    setState(() {
      _showPlusOptions = !_showPlusOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nickname = widget.roomData['r_title'] ?? '유저 닉네임';

    return Scaffold(
      appBar: AppBar(
        title: Text('일반채팅 : $nickname', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {}, // 알림 액션 필요 시 추가
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ChatContent(
                key: _chatContentKey,
                chatId: widget.roomData['r_id'],
                userId: widget.roomData['u1_id'],
                otherUserId: widget.roomData['u2_id'],
              ),
            ),
            if (_showPlusOptions)
              ChatPlusButton(roomData: widget.roomData),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _togglePlusOptions,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.add, color: Colors.lightBlue),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.lightBlue),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '메시지 입력',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.lightBlue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../SessionTokenManager.dart';
import 'ChatContent.dart';
import 'ChatPlusButton.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const ChatRoomScreen({
    required this.roomData,
    Key? key,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<ChatContentState> _chatContentKey = GlobalKey<ChatContentState>();
  bool _showPlusOptions = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    final token = await SessionTokenManager.getToken();

    socket = IO.io(
      'http://27.113.11.48:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u1_id': widget.roomData['u1_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      socket.connect(); // 재시도
    });

    socket.on('receiveMessage', (data) {
      _chatContentKey.currentState?.addMessage(data);
    });

    socket.connect();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final data = {
      'r_id': widget.roomData['r_id'],
      'u1_id': widget.roomData['u1_id'],
      'u2_id': widget.roomData['u2_id'],
      'message_contents': text,
      'send_date': DateTime.now().toIso8601String(),
    };

    socket.emit('sendMessage', data);
    _messageController.clear();
  }

  void _togglePlusOptions() {
    setState(() {
      _showPlusOptions = !_showPlusOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.roomData['r_title'] ?? '채팅방';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.lightBlue,
          ),
        ),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.lightBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatContent(
              key: _chatContentKey,
              chatId: widget.roomData['r_id'],
              userId: widget.roomData['u1_id'],
              otherUserId: widget.roomData['u2_id'],
            ),
          ),
          if (_showPlusOptions)
            ChatPlusButton(roomData: widget.roomData),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.lightBlue),
                    onPressed: _togglePlusOptions,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '메시지 입력',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.lightBlue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}