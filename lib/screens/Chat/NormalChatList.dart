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
  String? userId; // 로그인된 사용자 ID
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndChats();
  }

  Future<void> _fetchUserIdAndChats() async {
    try {
      // 사용자 ID 가져오기
      final userResponse = await SessionCookieManager.get(
          'http://54.180.54.31:3000/api/getUserInfo');

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        setState(() {
          userId = userData['userId']; // 사용자 ID 저장
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
            chatData['rooms']
                .where((room) => room['r_type'] == 'general'),
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

  Future<void> _joinRoomAndNavigate(BuildContext context, Map<String, dynamic> chat) async {
    final String apiUrl = 'http://54.180.54.31:3000/api/rooms/join';

    try {
      final response = await SessionCookieManager.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'r_id': chat['r_id'], 'u1_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == "방에 성공적으로 입장했습니다.") {
          final room = responseData['room'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatId: room['r_id'].toString(), // 방 ID
                chatTitle: room['r_title'] ?? '제목 없음', // 방 제목
                userId: userId ?? 'Unknown', // 세션에서 가져온 사용자 ID
              ),
            ),
          );
        } else {
          print('방 입장 실패: ${responseData['message']}');
        }
      } else {
        print('방 입장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('방 입장 오류: $e');
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
          onTap: () => _joinRoomAndNavigate(context, chat),
        );
      },
    );
  }
}