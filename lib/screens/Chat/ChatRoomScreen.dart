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
  late IO.Socket socket; // Socket.IO 클라이언트
  TextEditingController _messageController = TextEditingController(); // 메시지 입력 필드
  bool _showPlusOptions = false; // + 버튼 옵션 표시 여부

  @override
  void initState() {
    super.initState();
    _initializeSocket(); // 소켓 초기화
  }

  /// 소켓 초기화
  void _initializeSocket() {
    socket = IO.io(
      'http://54.180.54.31:3001',
      IO.OptionBuilder()
          .setTransports(['websocket']) // 웹소켓 연결 사용
          .disableAutoConnect() // 자동 연결 비활성화
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
      // 채팅방에 참가 메시지
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
      // 받은 메시지를 UI에 업데이트
      setState(() {
        // 여기에서 ChatContent에 메시지를 전달하거나 업데이트합니다.
      });
    });

    socket.connect(); // 소켓 연결
  }

  /// 메시지 전송
  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    // 메시지 전송
    socket.emit('sendMessage', {
      'r_id': widget.chatId,
      'u1_id': widget.userId,
      'u2_id': widget.otherUserId,
      'message_contents': _messageController.text,
    });

    print('Message sent: ${_messageController.text}');
    _messageController.clear(); // 입력 필드 초기화
  }

  /// + 버튼 눌렀을 때 옵션 표시/숨김
  void _togglePlusOptions() {
    setState(() {
      _showPlusOptions = !_showPlusOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle), // 채팅방 제목
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatContent(chatId: widget.chatId), // ChatContent 위젯 호출
          ),
          if (_showPlusOptions)
            ChatPlusButton( // ChatPlusButton을 현재 화면에 표시
              context: context,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add), // + 버튼
                  onPressed: _togglePlusOptions, // 옵션 표시/숨김 토글
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
                  onPressed: _sendMessage, // 메시지 전송
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
    socket.disconnect(); // 소켓 연결 해제
    socket.dispose(); // 소켓 리소스 정리
    _messageController.dispose(); // 입력 필드 해제
    super.dispose();
  }
}