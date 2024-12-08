import 'package:flutter/material.dart';
import 'dart:convert';
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
    final String apiUrl =
        'http://54.180.54.31:3000/chat/messages/${widget.chatId}';

    try {
      final response = await SessionCookieManager.get(apiUrl);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          messages = List<Map<String, dynamic>>.from(
              responseData.map((message) => Map<String, dynamic>.from(message)));
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
      messages.add(newMessage); // 새 메시지를 리스트에 추가
    });

    // 새 메시지가 추가되면 자동으로 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : messages.isEmpty
        ? Center(child: Text('메시지가 없습니다.'))
        : ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSender = message['u1_id'] == widget.userId;

        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 5.0, horizontal: 10.0),
          child: Align(
            alignment: isSender
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(12.0),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: isSender ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isSender
                      ? Radius.circular(12)
                      : Radius.zero,
                  bottomRight: isSender
                      ? Radius.zero
                      : Radius.circular(12),
                ),
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
                      color: isSender
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}