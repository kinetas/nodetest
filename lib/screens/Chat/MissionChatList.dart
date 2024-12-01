import 'package:flutter/material.dart';
import 'EnterChatRoom.dart'; // EnterChatRoom.dart 추가
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저
import 'DeleteChat.dart'; // 삭제 다이얼로그

class MissionChatList extends StatefulWidget {
  @override
  _MissionChatListState createState() => _MissionChatListState();
}

class _MissionChatListState extends State<MissionChatList> {
  List<Map<String, dynamic>> chatList = []; // 일반 채팅방 데이터
  bool isLoading = true; // 로딩 상태
  String? userId; // 현재 사용자 ID (u1_id)

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndChats();
  }

  Future<void> _fetchUserIdAndChats() async {
    try {
      // 사용자 ID 가져오기
      final userResponse = await SessionCookieManager.get(
        'http://54.180.54.31:3000/api/getUserInfo',
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        setState(() {
          userId = userData['userId']; // 현재 사용자 ID 저장
        });
      } else {
        print('사용자 정보 가져오기 실패: ${userResponse.statusCode}');
      }

      // 채팅방 목록 가져오기
      const String apiUrl = 'http://54.180.54.31:3000/api/rooms';
      final chatResponse = await SessionCookieManager.get(apiUrl);

      if (chatResponse.statusCode == 200) {
        final chatData = json.decode(chatResponse.body);
        print('Response data: ${chatResponse.body}'); // 디버깅용 로그 추가

        setState(() {
          // `r_type`이 'general'인 항목만 필터링하여 저장
          chatList = chatData['rooms'] != null
              ? List<Map<String, dynamic>>.from(
            chatData['rooms'].where((room) => room['r_type'] == 'open'),
          )
              : [];
          isLoading = false;
        });
      } else {
        print('일반 채팅방 목록 가져오기 실패: ${chatResponse.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('데이터 가져오기 오류: $e');
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
        return GestureDetector(
          onLongPress: () async {
            // 항목을 꾹 눌렀을 때 삭제 다이얼로그 표시
            final isDeleted = await showDialog(
              context: context,
              builder: (context) =>
                  DeleteChatDialog(u2Id: chat['r_id']),
            );

            // 삭제 후 목록 갱신
            if (isDeleted == true) {
              setState(() {
                chatList.removeAt(index);
              });
            }
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                chat['r_title'] != null && chat['r_title'].isNotEmpty
                    ? chat['r_title'][0]
                    : '?', // 제목 없을 때 대비
              ),
            ),
            title: Text(chat['r_title'] ?? '제목 없음'),
            subtitle: Text('상대방 ID: ${chat['u2_id']}'), // 상대방 ID 표시
            trailing: Text(chat['r_id'] ?? ''), // 방 ID 표시
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterChatroom(
                    rId: chat['r_id'], // 방 ID 전달
                    u2Id: chat['u2_id'], // 상대방 ID 전달
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}