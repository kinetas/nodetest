import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Badge 패키지 임포트
import 'dart:convert'; // JSON 파싱용
import '../../SessionCookieManager.dart';
import 'FriendSearchScreen.dart';
import 'AddFriendScreen.dart';
import 'FriendRequestScreen.dart';
import 'FriendClick.dart'; // 팝업 형태의 FriendClick 위젯

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
        _showErrorSnackBar('친구 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('네트워크 오류: $e');
    } finally {
      setState(() {
        isLoadingFriends = false;
      });
    }
  }

  // 알림 수 가져오기 (친구 요청 수)
  Future<void> _fetchNotificationCount() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/dashboard/friends/tfriends',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          notificationCount = responseData['receivedRequests']?.length ?? 0;
          isLoadingNotifications = false;
        });
      } else {
        _showErrorSnackBar('알림 수를 가져오는데 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('네트워크 오류: $e');
    } finally {
      setState(() {
        isLoadingNotifications = false;
      });
    }
  }

  // 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 친구 요청 화면으로 이동
  void _navigateToFriendRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendRequestScreen()),
    ).then((_) {
      _fetchNotificationCount(); // 친구 요청 수 업데이트
      _fetchFriends(); // 친구 목록 업데이트
    });
  }

  // 친구 검색 화면으로 이동
  void _navigateToFriendSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FriendSearchDialog(friends: friends);
      },
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
        // 상단 버튼 (알림, 검색, 추가)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            badges.Badge(
              showBadge: notificationCount > 0,
              badgeContent: Text(
                '$notificationCount', // 알림 수 표시
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
        Expanded(
          child: isLoadingFriends
              ? Center(child: CircularProgressIndicator())
              : friends.isEmpty
              ? Center(child: Text('친구 목록이 없습니다.'))
              : ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendId = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(friendId[0]), // ID의 첫 글자 표시
                ),
                title: Text('친구 ID: $friendId'),
                onTap: () {
                  // 친구를 클릭하면 팝업 표시
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FriendClick(friendId: friendId);
                    },
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