import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import '../../WebRTC/NewWebRTC/Call.dart'; // ✅ 수정된 경로
import '../../UserInfo/UserInfo_Id.dart'; // ✅ userId 가져오기 위한 import

class FriendClick extends StatelessWidget {
  final String friendId;

  const FriendClick({required this.friendId});

  Future<void> _deleteFriend(BuildContext context) async {
    final String apiUrl = 'http://27.113.11.48:3000/auth/dashboard/friends/delete';

    try {
      final response = await SessionTokenManager.delete(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'f_id': friendId}),
      );

      print("🧨 [Delete Friend] ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? '친구 삭제 성공')),
          );
        } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  void _startVideoCall(BuildContext context) async {
    final userInfo = UserInfoId();
    final myId = await userInfo.fetchUserId();

    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내 ID를 불러올 수 없습니다.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          isCaller: true,
          myId: myId,
          friendId: friendId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
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
                                      Navigator.pop(context);
                                      _deleteFriend(context);
                                    },
                                    child: Text('확인', style: TextStyle(color: Colors.red)),
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
                  child: Text(friendId[0]),
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
                      icon: Icon(Icons.call, size: 32, color: Colors.lightBlue),
                      onPressed: () => _startVideoCall(context), // ✅ 수정된 버튼
                    ),
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