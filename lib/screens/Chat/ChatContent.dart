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
  ChatContentState createState() => ChatContentState(); // 이름 변경
}

class ChatContentState extends State<ChatContent> { // 이름 변경 및 public 설정
  List<Map<String, dynamic>> messages = []; // 채팅 메시지 리스트
  bool isLoading = true; // 로딩 상태
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // 메시지 가져오기 호출
  }

  /// 메시지 가져오기
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
          isLoading = false; // 로딩 완료
        });

        // 로드 완료 후 스크롤을 맨 아래로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        print('메시지 가져오기 실패: ${response.statusCode}');
        setState(() {
          isLoading = false; // 실패 시 로딩 종료
        });
      }
    } catch (e) {
      print('메시지 가져오기 오류: $e');
      setState(() {
        isLoading = false; // 네트워크 오류 시 로딩 종료
      });
    }
  }

  /// 새로운 메시지를 받을 때 자동으로 맨 아래로 스크롤
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// 새 메시지를 화면에 추가
  void addMessage(Map<String, dynamic> newMessage) {
    setState(() {
      messages.add(newMessage); // 새로운 메시지를 리스트 끝에 추가
    });

    // 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // 로딩 중
        : messages.isEmpty
        ? Center(child: Text('메시지가 없습니다.')) // 메시지가 없을 때
        : ListView.builder(
      controller: _scrollController, // 스크롤 컨트롤러 추가
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSender =
            message['u1_id'] == widget.userId; // 내가 보낸 메시지 여부

        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 5.0, horizontal: 10.0),
          child: Align(
            alignment: isSender
                ? Alignment.centerRight // 내가 보낸 메시지는 오른쪽
                : Alignment.centerLeft, // 상대가 보낸 메시지는 왼쪽
            child: Container(
              padding: EdgeInsets.all(12.0),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color:
                isSender ? Colors.blue : Colors.grey[300], // 색상
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                  isSender ? Radius.circular(12) : Radius.zero,
                  bottomRight:
                  isSender ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message_contents'] ?? '빈 메시지',
                    style: TextStyle(
                      color:
                      isSender ? Colors.white : Colors.black, // 텍스트 색상
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
    _scrollController.dispose(); // 스크롤 컨트롤러 해제
    super.dispose();
  }
}