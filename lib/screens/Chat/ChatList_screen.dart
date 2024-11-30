import 'package:flutter/material.dart';
import 'ChatRoomScreen.dart';
import 'dart:convert'; // JSON 작업을 위해 dart:convert 추가
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저

class ChatList extends StatefulWidget {
  final List<Map<String, String>> chatList;

  ChatList({required this.chatList});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String? userId; // 로그인된 사용자 ID

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      final response = await SessionCookieManager.get('http://54.180.54.31:3000/api/getUserInfo');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userId = responseData['userId']; // 서버에서 반환된 사용자 ID
        });
      } else {
        print('사용자 정보를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('사용자 정보 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: widget.chatList.length,
      itemBuilder: (context, index) {
        final chat = widget.chatList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat['title'] != null && chat['title']!.isNotEmpty
                ? chat['title']![0]
                : '?'), // 방 제목 첫 글자
          ),
          title: Text(chat['title'] ?? '제목 없음'),
          subtitle: Text(chat['lastMessage'] ?? '메시지가 없습니다.'),
          trailing: Text(chat['time'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  chatId: chat['id'] ?? '', // 방 ID
                  chatTitle: chat['title'] ?? '제목 없음', // 방 제목
                  userId: userId ?? 'Unknown', // 로그인된 사용자 ID
                ),
              ),
            );
          },
        );
      },
    );
  }
}