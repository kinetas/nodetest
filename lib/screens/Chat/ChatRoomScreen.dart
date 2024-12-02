import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'ChatContent.dart'; // ChatContent를 import
import 'ChatPlusButton.dart'; // ChatPlusButton을 import

class ChatRoomScreen extends StatefulWidget {
  final String chatId; // 채팅방 ID
  final String chatTitle; // 채팅방 제목
  final String userId; // 유저 아이디
  final String otherUserId; // 상대방 아이디

  const ChatRoomScreen({
    required this.chatId,
    required this.chatTitle,
    required this.userId,
    required this.otherUserId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket;
  TextEditingController _messageController = TextEditingController();
  bool _showPlusOptions = false;
  final GlobalKey<ChatContentState> _chatContentKey = GlobalKey<ChatContentState>(); // ChatContent 상태 접근용 Key

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io(
      'http://54.180.54.31:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
      debugPrint('joinRoom: ${{
        'r_id': widget.chatId,
        'u1_id': widget.userId,
      }}');
      socket.emit('joinRoom', {
        'r_id': widget.chatId,
        'u1_id': widget.userId,
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.on('receiveMessage', (data) {
      print('Message received: $data');
      _chatContentKey.currentState?.addMessage(data); // 메시지 업데이트
    });

    socket.connect();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final messageData = {
      'r_id': widget.chatId,
      'u1_id': widget.userId,
      'u2_id': widget.otherUserId,
      'message_contents': _messageController.text,
      'send_date': DateTime.now().toString(), // 임시로 현재 시간 추가
    };

    socket.emit('sendMessage', messageData);
    print('Message sent: ${_messageController.text}');
    _messageController.clear();

    // 메시지를 ChatContent에도 바로 추가
    _chatContentKey.currentState?.addMessage(messageData);
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
        title: Text(widget.chatTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatContent(
              key: _chatContentKey, // GlobalKey를 ChatContent에 전달
              chatId: widget.chatId,
              userId: widget.userId,
              otherUserId: widget.otherUserId,
            ),
          ),
          if (_showPlusOptions)
            ChatPlusButton(
              context: context,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _togglePlusOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }
}