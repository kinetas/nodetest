import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Badge 패키지 임포트
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../SessionCookieManager.dart';
import 'FriendSearch_screen.dart'; // Adjust the import paths as needed
import 'AddFriend_screen.dart';   // Adjust the import paths as needed
import 'FriendRequestScreen.dart'; // Adjust the import paths as needed

class FriendListWidget extends StatefulWidget {
  @override
  _FriendListWidgetState createState() => _FriendListWidgetState();
}

class _FriendListWidgetState extends State<FriendListWidget> {
  List<String> friends = []; // 친구 목록 저장
  int notificationCount = 0; // 친구 요청 알림 수
  bool isLoadingFriends = true; // 친구 목록 로딩 상태
  bool isLoadingNotifications = true; // 알림 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchFriends(); // 친구 목록 가져오기
    _fetchNotificationCount(); // 알림 수 가져오기
  }

  // 친구 목록 가져오기
  Future<void> _fetchFriends() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/dashboard/friends/ifriends',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          friends = responseData['iFriends'] != null
              ? List<String>.from(responseData['iFriends'])
              : [];
          isLoadingFriends = false;
        });
      } else {
        setState(() => isLoadingFriends = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 목록을 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      setState(() => isLoadingFriends = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  // 알림 수 가져오기 (친구 요청 수)
  Future<void> _fetchNotificationCount() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/dashboard/friends/tfriends', // 친구 요청 목록 API
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          notificationCount = responseData['receivedRequests'] != null
              ? responseData['receivedRequests'].length
              : 0;
          isLoadingNotifications = false;
        });
      } else {
        setState(() => isLoadingNotifications = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알람 수를 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      setState(() => isLoadingNotifications = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  // 친구 요청 화면으로 이동
  void _navigateToFriendRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendRequestScreen()),
    ).then((_) {
      // 친구 요청 화면에서 돌아오면 알람 수와 친구 목록 다시 가져오기
      _fetchNotificationCount();
      _fetchFriends();
    });
  }

  // 친구 검색 화면으로 이동
  void _navigateToFriendSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendSearchScreen()),
    );
  }

  // 친구 추가 화면으로 이동
  void _navigateToAddFriend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFriendScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 버튼 (종 모양, 검색, 추가)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 종 모양 아이콘에 알람 수 표시
            badges.Badge(
              showBadge: notificationCount > 0,
              badgeContent: Text(
                '$notificationCount', // 알람 수
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeColor: Colors.red,
              child: IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => _navigateToFriendRequests(context),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _navigateToFriendSearch(context),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToAddFriend(context),
            ),
          ],
        ),
        // 친구 목록 표시
        isLoadingFriends
            ? Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : friends.isEmpty
            ? Expanded(
          child: Center(
            child: Text('친구 목록이 없습니다.'),
          ),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendId = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(friendId[0]), // f_id의 첫 글자
                ),
                title: Text('친구 ID: $friendId'), // f_id 표시
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$friendId 선택됨')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}