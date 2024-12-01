import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 쿠키 매니저 사용

class ChatContent extends StatefulWidget {
  final String chatId; // 채팅방 ID

  const ChatContent({
    required this.chatId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatContentState createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent> {
  List<Map<String, dynamic>> messages = []; // 채팅 메시지 리스트
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // 메시지 가져오기 호출
  }

  /// 메시지 가져오기
  Future<void> _fetchMessages() async {
    final String apiUrl = 'http://54.180.54.31:3000/chat/messages/${widget.chatId}';

    try {
      // SessionCookieManager를 통해 GET 요청
      print('Requesting URL: $apiUrl');
      final response = await SessionCookieManager.get(apiUrl);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // 응답 데이터를 메시지 리스트에 저장
        setState(() {
          messages = List<Map<String, dynamic>>.from(responseData.map((message) => Map<String, dynamic>.from(message)));
          isLoading = false; // 로딩 완료
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // 로딩 중
        : messages.isEmpty
        ? Center(child: Text('메시지가 없습니다.')) // 메시지가 없을 때
        : ListView.builder(
      reverse: true, // 최신 메시지가 위로
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ListTile(
          title: Text(message['message_contents'] ?? '빈 메시지'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보낸 시간: ${message['send_date'] ?? ''}',
                style: TextStyle(fontSize: 10),
              ),
              if (message['image'] != null)
                Text(
                  '이미지 첨부: ${message['image_type'] ?? '알 수 없음'}',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          trailing: Text(
            message['u1_id'] == widget.chatId ? '나' : '상대방',
          ),
        );
      },
    );
  }
}