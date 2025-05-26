/*
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ delete 메서드 사용

class FriendClick extends StatelessWidget {
  final String friendId;

  const FriendClick({required this.friendId});

  Future<void> _deleteFriend(BuildContext context) async {
    final String apiUrl = 'http://27.113.11.48:3000/dashboard/friends/delete';

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
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import '../../WebRTC/WebRTCChatScreen.dart';

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

  Future<void> _startVideoCall(BuildContext context) async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/auth/api/user-info/user-id',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final myId = responseData['u_id'];

        if (myId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebRTCChatScreen(
                friendId: friendId,
              ),
            ),
          );
        } else {
          throw Exception("사용자 ID 응답에 없음");
        }
      } else {
        throw Exception("사용자 ID 불러오기 실패");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("내 ID를 불러오지 못했습니다: $e")),
      );
    }
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
                            builder: (context) => AlertDialog(
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
                            ),
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
                    IconButton(
                      icon: Icon(Icons.video_call, size: 36, color: Colors.redAccent),
                      onPressed: () {
                        _startVideoCall(context);
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