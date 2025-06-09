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
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      print('⚠️ Socket disconnected');
    });

    socket.on('receiveMessage', (data) {
      print('📥 Message received: $data');
      _chatContentKey.currentState?.addMessage(data);
    });

    socket.connect();
  }

  void _sendMessage({String? base64Image, String? imageType}) {
    final messageContent = _messageController.text.trim();
    if (messageContent.isEmpty && base64Image == null) return;

    final messageData = {
      'r_id': widget.roomData['r_id'],
      'u2_id': widget.roomData['u2_id'],
      if (messageContent.isNotEmpty) 'message_contents': messageContent,
      if (base64Image != null) 'image': base64Image,
      if (imageType != null) 'image_type': imageType,
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
    );
  }
}