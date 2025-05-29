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
      print('[SOCKET] ✅ Connected to server');
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u1_id': widget.roomData['u1_id'],
        'u2_id': widget.roomData['u2_id'],
      });
      print('[SOCKET] Join room emitted');
    });

    socket.onDisconnect((_) {
      print('[SOCKET] ❌ Disconnected from server');
      // 자동 재연결 시도
      Future.delayed(Duration(seconds: 1), () {
        socket.connect();
      });
    });

    // 서버에서 메시지 수신
    socket.on('receiveMessage', (data) {
      print('[SOCKET] 📥 Received message from server: $data');
      _chatContentKey.currentState?.addMessage(data);
    });

    // 서버에서 에러 수신
    socket.on('error', (err) {
      print('[SOCKET] ❌ Error event: $err');
    });
    socket.onConnectError((err) {
      print('[SOCKET] ❗ Connect error: $err');
    });

    // (옵션) 서버에서 ack 콜백 커스텀 이벤트
    socket.on('sendMessageAck', (data) {
      print('[SOCKET] 📨 서버로부터 sendMessageAck 콜백: $data');
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

    print('[SOCKET] 📨 Sending message to server: $data');

    // 서버에 emitWithAck로 ack 응답까지 로그로 받음 (서버가 콜백 구현해야 함)
    socket.emitWithAck('sendMessage', data, ack: (response) {
      print('[SOCKET] 🔔 서버에서 즉시 응답(ACK): $response');
    });

    // UX상 즉시 내 채팅창에 메시지 추가 (서버에서 다시 push될 수도 있음)
    _chatContentKey.currentState?.addMessage(data);

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
