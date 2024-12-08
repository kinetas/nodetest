import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'ChatContent.dart'; // ChatContent import
import 'ChatPlusButton.dart'; // ChatPlusButton import

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> roomData; // roomData를 받도록 수정

  const ChatRoomScreen({
    required this.roomData,
    Key? key,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late IO.Socket socket; // Socket.IO 클라이언트
  final TextEditingController _messageController = TextEditingController();
  bool _showPlusOptions = false; // "+" 버튼 옵션 표시 여부
  final GlobalKey<ChatContentState> _chatContentKey = GlobalKey<ChatContentState>(); // ChatContent 상태 접근용 Key

  @override
  void initState() {
    super.initState();
    _initializeSocket(); // 소켓 초기화
  }

  @override
  void dispose() {
    socket.disconnect(); // 소켓 연결 해제
    socket.dispose();
    _messageController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  void _initializeSocket() {
    print('Initializing socket for room: ${widget.roomData['r_id']}');

    socket = IO.io(
      'http://54.180.54.31:3001',
      IO.OptionBuilder()
          .setTransports(['websocket']) // WebSocket 사용
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u1_id': widget.roomData['u1_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      socket.connect(); // 연결 끊어질 경우 재연결
    });

    // 메시지 수신 이벤트
    socket.on('receiveMessage', (data) {
      print('Message received: $data');
      // ChatContent 상태에 메시지 추가
      if (_chatContentKey.currentState != null) {
        _chatContentKey.currentState?.addMessage(data);
      }
    });

    socket.connect(); // 소켓 연결 시작
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

    print('Sending message: $messageData');

    // 서버에 메시지 전송
    socket.emit('sendMessage', messageData);

    // 입력 필드 초기화
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
        title: Text(widget.roomData['r_title'] ?? '채팅방'),
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
}