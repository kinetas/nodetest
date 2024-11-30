import 'package:flutter/material.dart';
import 'ChatRoomScreen.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저

class NormalChatList extends StatefulWidget {
  @override
  _NormalChatListState createState() => _NormalChatListState();
}

class _NormalChatListState extends State<NormalChatList> {
  List<Map<String, dynamic>> chatList = []; // 일반 채팅방 데이터
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchNormalChats();
  }

  Future<void> _fetchNormalChats() async {
    const String apiUrl = 'http://54.180.54.31:3000/api/rooms'; // 방 목록 가져오기 API 주소

    try {
      final response = await SessionCookieManager.get(apiUrl);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response data: ${response.body}'); // 디버깅용 로그 추가

        setState(() {
          // `r_type`이 'general'인 항목만 필터링하여 저장
          chatList = responseData['rooms'] != null
              ? List<Map<String, dynamic>>.from(
              responseData['rooms'].where((room) => room['r_type'] == 'general'))
              : [];
          isLoading = false;
        });
      } else {
        print('일반 채팅방 목록 가져오기 실패: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('일반 채팅방 목록 가져오기 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : chatList.isEmpty
        ? Center(child: Text('채팅방이 없습니다.'))
        : ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              chat['r_title'] != null && chat['r_title'].isNotEmpty
                  ? chat['r_title'][0]
                  : '?', // 제목 없을 때 대비
            ),
          ),
          title: Text(chat['r_title'] ?? '제목 없음'),
          subtitle: Text('참여자: ${chat['u1_id']} - ${chat['u2_id']}'),
          trailing: Text(chat['r_id'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  chatId: chat['r_id'].toString(), // String 변환
                ),
              ),
            );
          },
        );
      },
    );
  }
}