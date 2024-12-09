import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../SessionCookieManager.dart'; // 쿠키 매니저 사용

class ChatContent extends StatefulWidget {
  final String chatId; // 채팅방 ID
  final String userId; // 현재 사용자 ID
  final String otherUserId; // 상대방 ID

  const ChatContent({
    required this.chatId,
    required this.userId,
    required this.otherUserId,
    Key? key,
  }) : super(key: key);

  @override
  ChatContentState createState() => ChatContentState();
}

class ChatContentState extends State<ChatContent> {
  List<Map<String, dynamic>> messages = []; // 채팅 메시지 리스트
  bool isLoading = true; // 로딩 상태
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // 메시지 가져오기 호출
  }

  Future<void> _fetchMessages() async {
    final String apiUrl = 'http://54.180.54.31:3000/chat/messages/${widget.chatId}';

    try {
      final response = await SessionCookieManager.get(apiUrl);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(responseData);
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void addMessage(Map<String, dynamic> newMessage) {
    setState(() {
      messages.add(newMessage);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
          ),
        )
            : messages.isEmpty
            ? Center(
          child: Text(
            '메시지가 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isSender = message['u1_id'] == widget.userId;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: Align(
                alignment: isSender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: message['image'] != null
                    ? _buildImageMessage(message, isSender)
                    : _buildTextMessage(message, isSender),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isSender) {
    return Container(
      padding: EdgeInsets.all(12.0),
      constraints: BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: isSender ? Colors.lightBlue : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: isSender ? Radius.circular(12) : Radius.zero,
          bottomRight: isSender ? Radius.zero : Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['message_contents'] ?? '빈 메시지',
            style: TextStyle(
              color: isSender ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            message['send_date'] ?? '',
            style: TextStyle(
              color: isSender ? Colors.white70 : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message, bool isSender) {
    try {
      final List<dynamic> imageData = message['image']['data'];
      final Uint8List imageBytes = Uint8List.fromList(imageData.cast<int>());

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                },
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            message['send_date'] ?? '',
            style: TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ],
      );
    } catch (e) {
      print("Image decoding error: $e");
      return Icon(Icons.broken_image, size: 100, color: Colors.grey);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}