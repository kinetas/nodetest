import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:convert';
import '../../SessionTokenManager.dart';
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
        'http://13.125.65.151:3000/auth/dashboard/friends/ifriends',
      );

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
        'http://13.125.65.151:3000/auth/dashboard/friends/tfriends',
      );

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
    final Color primaryColor = Colors.black87;
    final Color cardColor = Colors.white;
    final Color textColor = Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀 & 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '친구 목록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Row(
                children: [
                  badges.Badge(
                    showBadge: notificationCount > 0,
                    badgeContent: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    position: badges.BadgePosition.topEnd(top: -2, end: -2),
                    badgeStyle: badges.BadgeStyle(badgeColor: Colors.redAccent),
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      color: primaryColor,
                      onPressed: () => _navigateToFriendRequests(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: primaryColor,
                    onPressed: () => _navigateToFriendSearch(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    color: primaryColor,
                    onPressed: () => _navigateToAddFriend(context),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 친구 리스트
        Expanded(
          child: isLoadingFriends
              ? const Center(child: CircularProgressIndicator())
              : friends.isEmpty
              ? Center(
            child: Text(
              '친구 목록이 없습니다.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final friendId = friends[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => FriendClick(friendId: friendId),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          friendId[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        friendId,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}