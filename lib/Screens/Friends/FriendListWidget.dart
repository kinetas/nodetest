import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ 토큰 기반 요청 처리
import 'FriendSearchScreen.dart';
import 'AddFriendScreen.dart';
import 'FriendRequestScreen.dart';
import 'FriendClick.dart';

class FriendListWidget extends StatefulWidget {
  @override
  _FriendListWidgetState createState() => _FriendListWidgetState();
}

class _FriendListWidgetState extends State<FriendListWidget> {
  List<String> friends = [];
  int notificationCount = 0;
  bool isLoadingFriends = true;
  bool isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchNotificationCount();
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/dashboard/friends/ifriends',
      );

      print("📦 [Friends GET] ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          friends = List<String>.from(responseData['iFriends'] ?? []);
        });
      } else {
        _showErrorSnackBar('친구 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('네트워크 오류: $e');
    } finally {
      setState(() => isLoadingFriends = false);
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/dashboard/friends/tfriends',
      );

      print("📦 [Notifications GET] ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          notificationCount = (responseData['receivedRequests']?.length ?? 0);
        });
      } else {
        _showErrorSnackBar('알림 수를 가져오는데 실패했습니다.');
      }
    } catch (e) {
      _showErrorSnackBar('네트워크 오류: $e');
    } finally {
      setState(() => isLoadingNotifications = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToFriendRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendRequestScreen()),
    ).then((_) {
      _fetchNotificationCount();
      _fetchFriends();
    });
  }

  void _navigateToFriendSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FriendSearchDialog(friends: friends);
      },
    );
  }

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
                '$notificationCount',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeStyle: badges.BadgeStyle(badgeColor: Colors.red),
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
                leading: CircleAvatar(child: Text(friendId[0])),
                title: Text('친구 ID: $friendId'),
                onTap: () {
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