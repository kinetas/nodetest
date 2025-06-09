import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
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
    final String apiUrl = 'http://27.113.11.48:3000/nodetest/chat/messages/${widget.chatId}';

    try {
      final response = await SessionTokenManager.get(apiUrl);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        messagesNotifier.value = List<Map<String, dynamic>>.from(responseData);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
          if (messages.isEmpty) {
            return Center(
              child: Text('메시지가 없습니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSender = message['u1_id'] == widget.userId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment:
                  isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      message['image'] != null
                          ? _buildImageMessage(message, isSender)
                          : _buildTextMessage(message, isSender),
                      Padding(
                        padding: EdgeInsets.only(top: 2, left: 4, right: 4),
                        child: Text(
                          _formatTime(message['send_date']),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isSender) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      constraints: BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: isSender ? Color(0xFFB3E5FC) : Color(0xFFF1F1F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(isSender ? 14 : 0),
          bottomRight: Radius.circular(isSender ? 0 : 14),
        ),
      ),
      child: Text(
        message['message_contents'] ?? '',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> message, bool isSender) {
    try {
      final List<dynamic> imageData = message['image']['data'];
      final Uint8List imageBytes = Uint8List.fromList(imageData.cast<int>());
      return Container(
        constraints: BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
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
      );
    } catch (e) {
      print("Image decoding error: $e");
      return Icon(Icons.broken_image, size: 100, color: Colors.grey);
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final hour = dt.hour > 12 ? '오후' : '오전';
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return "$hour $hour12:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messagesNotifier.dispose();
    super.dispose();
  }
}