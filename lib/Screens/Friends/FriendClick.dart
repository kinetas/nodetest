import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

class FriendClick extends StatelessWidget {
  final String friendId;

  const FriendClick({required this.friendId});

  Future<void> _deleteFriend(BuildContext context) async {
    final String apiUrl = 'http://54.180.54.31:3000/dashboard/friends/delete';

    try {
      final response = await SessionCookieManager.delete(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'f_id': friendId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // 성공적으로 삭제
          Navigator.pop(context); // 팝업 닫기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? '친구 삭제 성공')),
          );
        } else {
          // 삭제 실패
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? '친구 삭제 실패')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 삭제 요청 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // 네트워크 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // 팝업 외부를 클릭하면 닫힘
      },
      child: Material(
        color: Colors.black.withOpacity(0.5), // 뒤 화면 흐리게
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3, // 화면 2/3 크기
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('친구 삭제하기'),
                                content: Text('정말로 친구를 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // 알림 창 닫기
                                      _deleteFriend(context); // 친구 삭제 요청
                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 50,
                  child: Text(friendId[0]), // ID의 첫 글자 표시
                ),
                SizedBox(height: 16),
                Text(
                  '친구 ID: $friendId',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chat, size: 32, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('채팅 기능 구현 예정')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.assignment, size: 32, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('미션 생성 기능 구현 예정')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}