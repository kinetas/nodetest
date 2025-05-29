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
  List<Map<String, dynamic>> messages = [];
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
        setState(() {
          messages = List<Map<String, dynamic>>.from(responseData);
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
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
    return Container(
      color: Colors.white,
      child: isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue)))
          : messages.isEmpty
          ? Center(child: Text('메시지가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        children: _buildMessageList(),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    List<Widget> widgets = [];
    String? lastDate;
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isSender = message['u1_id'] == widget.userId;
      final dateTime = message['send_date'] ?? '';
      final date = dateTime.length >= 10 ? dateTime.substring(0, 10) : '';

      // 날짜라벨 (00시 넘어갈 때)
      if (lastDate != date) {
        widgets.add(
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 6),
                  Text(
                    _formatDateFull(message['send_date']),
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
        );
        lastDate = date;
      }
    }

    // 시간표기: 같은 화자/같은 분이면 마지막 메시지에만 시간
    // 메시지들을 그룹화(화자, 분 단위로)
    List<_MsgGroup> grouped = [];
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final user = msg['u1_id'];
      final dateTimeStr = msg['send_date'] ?? '';
      DateTime? dt;
      try { dt = DateTime.parse(dateTimeStr).toLocal(); } catch (_) {}
      String minuteKey = dt != null ? "${user}_${dt.year}_${dt.month}_${dt.day}_${dt.hour}_${dt.minute}" : "";

      if (grouped.isNotEmpty &&
          grouped.last.minuteKey == minuteKey) {
        grouped.last.messages.add(msg);
      } else {
        grouped.add(_MsgGroup(user: user, minuteKey: minuteKey, messages: [msg]));
      }
    }

    // 실제 위젯화
    lastDate = null;
    for (var group in grouped) {
      for (int i = 0; i < group.messages.length; i++) {
        final msg = group.messages[i];
        final isSender = msg['u1_id'] == widget.userId;
        final dateTime = msg['send_date'] ?? '';
        final date = dateTime.length >= 10 ? dateTime.substring(0, 10) : '';

        if (lastDate != date) {
          widgets.add(
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      _formatDateFull(msg['send_date']),
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
          );
          lastDate = date;
        }

        widgets.add(
          Align(
            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                msg['image'] != null
                    ? _buildImageMessage(msg, isSender)
                    : _buildTextMessage(msg, isSender),
                if (i == group.messages.length - 1)
                  Padding(
                    padding: EdgeInsets.only(top: 2, left: 4, right: 4),
                    child: Text(
                      _formatTime(msg['send_date']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
                // ✅ 버블 간격 항상 유지!
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
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

  String _formatDateFull(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final weekDays = ['월요일','화요일','수요일','목요일','금요일','토요일','일요일'];
      return "${dt.year}년 ${dt.month}월 ${dt.day}일 ${weekDays[dt.weekday-1]}";
    } catch (e) {
      return '';
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
    super.dispose();
  }
}

class _MsgGroup {
  final String user;
  final String minuteKey;
  final List<Map<String, dynamic>> messages;
  _MsgGroup({required this.user, required this.minuteKey, required this.messages});
}
