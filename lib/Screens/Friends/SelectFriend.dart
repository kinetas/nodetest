import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class SelectFriendScreen extends StatefulWidget {
  const SelectFriendScreen({Key? key}) : super(key: key);

  @override
  State<SelectFriendScreen> createState() => _SelectFriendScreenState();
}

class _SelectFriendScreenState extends State<SelectFriendScreen> {
  List<String> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
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
        _showError('친구 목록을 불러오지 못했습니다.');
      }
    } catch (e) {
      _showError('네트워크 오류: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 선택'),
        backgroundColor: Colors.lightBlue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? const Center(child: Text('친구가 없습니다.'))
          : ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friendId = friends[index];
          return ListTile(
            leading: CircleAvatar(child: Text(friendId[0])),
            title: Text(friendId),
            onTap: () {
              Navigator.pop(context, friendId); // 선택된 친구 ID 반환
            },
          );
        },
      ),
    );
  }
}