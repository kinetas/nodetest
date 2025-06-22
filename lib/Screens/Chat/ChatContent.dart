import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../SessionTokenManager.dart';

class ChatContent extends StatefulWidget {
  final String chatId;
  final String userId;
  final String otherUserId;

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
  final ValueNotifier<List<Map<String, dynamic>>> messagesNotifier = ValueNotifier([]);
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final String apiUrl = 'http://13.125.65.151:3000/nodetest/chat/messages/${widget.chatId}';

    try {
      final response = await SessionTokenManager.get(apiUrl);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        messagesNotifier.value = List<Map<String, dynamic>>.from(responseData);
      }
    } catch (e) {
      print('❌ Error fetching messages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(position, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  void addMessage(Map<String, dynamic> newMessage) {
    messagesNotifier.value = [...messagesNotifier.value, newMessage];
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
        ),
      )
          : ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: messagesNotifier,
        builder: (context, messages, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          if (messages.isEmpty) {
            return Center(
              child: Text('메시지가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSender = message['u1_id'] == widget.userId;
              final sendTime = DateTime.parse(message['send_date']).toLocal();
              final dateStr = DateFormat('yyyy-MM-dd').format(sendTime);
              final timeStr = DateFormat('a h:mm', 'ko_KR').format(sendTime);
              final minuteKey = '${sendTime.hour}:${sendTime.minute}';

              bool showTime = true;
              if (index + 1 < messages.length) {
                final nextMsg = messages[index + 1];
                final nextTime = DateTime.parse(nextMsg['send_date']).toLocal();
                final nextMinuteKey = '${nextTime.hour}:${nextTime.minute}';
                final sameSender = nextMsg['u1_id'] == message['u1_id'];
                final sameMinute = nextMinuteKey == minuteKey;
                if (sameSender && sameMinute) showTime = false;
              }

              List<Widget> children = [];

              if (index == 0 ||
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(messages[index - 1]['send_date']).toLocal()) != dateStr) {
                children.add(Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(sendTime),
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ),
                ));
              }

              children.add(
                Align(
                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: isSender
                        ? [
                      if (showTime)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ),
                      message['image'] != null ? _buildImageMessage(message) : _buildTextMessage(message, isSender),
                    ]
                        : [
                      message['image'] != null ? _buildImageMessage(message) : _buildTextMessage(message, isSender),
                      if (showTime)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ),
                    ],
                  ),
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(children: children),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isSender) {
    final content = message['message_contents'] ?? (message['image'] != null ? '[이미지]' : '');
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: EdgeInsets.only(top: 4),
      constraints: BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: isSender ? Colors.lightBlueAccent.shade100 : Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(isSender ? 16 : 0),
          bottomRight: Radius.circular(isSender ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Text(content, style: TextStyle(fontSize: 15, color: Colors.black87)),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message) {
    try {
      Uint8List? imageBytes;

      if (message['image'] is String) {
        final base64Str = message['image'];
        final cleaned = base64Str.contains(',') ? base64Str.split(',').last : base64Str;
        imageBytes = base64Decode(cleaned);
      } else if (message['image'] is Map && message['image']['data'] is List) {
        final imageData = message['image']['data'];
        imageBytes = Uint8List.fromList(List<int>.from(imageData));
      } else {
        throw Exception("지원되지 않는 이미지 형식");
      }

      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: InteractiveViewer(child: Image.memory(imageBytes!)),
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(imageBytes!, fit: BoxFit.cover),
          ),
        ),
      );
    } catch (e) {
      print("❌ 이미지 디코딩 오류: $e");
      return Icon(Icons.broken_image, size: 100, color: Colors.grey);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messagesNotifier.dispose();
    super.dispose();
  }
}