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
    print('🧹 소켓 연결 해제 및 컨트롤러 dispose');
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    final token = await SessionTokenManager.getToken();
    print('🔐 JWT Token for Socket: $token');

    socket = IO.io(
      'http://13.125.65.151:3000/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setPath('/socket.io')
          .build(),
    );

    socket.onConnect((_) {
      print('✅ [Socket] Connected');
      print('📡 joinRoom emit: r_id=${widget.roomData['r_id']}, u2_id=${widget.roomData['u2_id']}');
      socket.emit('joinRoom', {
        'r_id': widget.roomData['r_id'],
        'u2_id': widget.roomData['u2_id'],
      });
    });

    socket.onDisconnect((_) {
      print('⚠️ [Socket] Disconnected');
    });

    socket.onConnectError((error) {
      print('❌ [Socket] Connect Error: $error');
    });

    socket.onError((error) {
      print('❌ [Socket] Error: $error');
    });

    socket.on('receiveMessage', (data) {
      print('📥 [Socket] Message received from server: $data');
      _chatContentKey.currentState?.addMessage(data);
    });

    socket.connect();
  }

  void _sendMessage({String? base64Image, String? imageType}) {
    final messageContent = _messageController.text.trim();
    final hasText = messageContent.isNotEmpty;
    final hasImage = base64Image != null;

    print('📝 [Message] Preparing to send...');
    print('🔎 message: "$messageContent"');
    print('🔎 base64Image: ${base64Image != null ? "YES (${base64Image.length} chars)" : "NO"}');
    print('🔎 imageType: $imageType');

    if (!hasText && !hasImage) {
      print('⚠️ [Message] No content to send (text or image required)');
      return;
    }

    final messageData = {
      'r_id': widget.roomData['r_id'],
      'u2_id': widget.roomData['u2_id'],
      if (hasText) 'message_contents': messageContent,
      if (hasImage) 'image': base64Image,
      if (imageType != null) 'image_type': imageType,
    };

    print('📤 [Socket] Emitting sendMessage: $messageData');

    if (socket.connected) {
      socket.emit('sendMessage', messageData);
      print('✅ [Socket] sendMessage emitted');
    } else {
      print('❌ [Socket] Not connected — sendMessage emit failed');
    }

    _messageController.clear();
  }

  void _togglePlusOptions() {
    setState(() {
      _showPlusOptions = !_showPlusOptions;
      print('➕ [UI] Plus options ${_showPlusOptions ? "shown" : "hidden"}');
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
                  onPressed: () {
                    print('📨 [UI] Send button clicked');
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}