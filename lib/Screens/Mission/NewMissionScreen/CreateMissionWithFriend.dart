import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../SessionTokenManager.dart';
import 'CreateMissionScreen.dart';
import '../../../UserInfo/UserInfo_Id.dart'; // ✅ 수정된 부분

class CreateMissionWithFriend extends StatefulWidget {
  final String? initialTitle;
  final String? initialCategory;

  const CreateMissionWithFriend({
    super.key,
    this.initialTitle,
    this.initialCategory,
  });

  @override
  State<CreateMissionWithFriend> createState() => _CreateMissionWithFriendState();
}

class _CreateMissionWithFriendState extends State<CreateMissionWithFriend> {
  List<String> friends = [];
  String? selectedFriendId;
  String? myUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyId();       // 내 ID 가져오기
    _fetchFriends();    // 친구 목록 가져오기
  }

  Future<void> _fetchMyId() async {
    try {
      final userId = await UserInfoId().fetchUserId(); // ✅ UserInfoId로 변경
      if (userId != null) {
        setState(() {
          myUserId = userId;
        });
      } else {
        _showError('내 사용자 정보를 불러올 수 없습니다.');
      }
    } catch (e) {
      _showError('내 정보 불러오기 실패: $e');
    }
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

  void _selectFriend(String friendId) {
    setState(() {
      selectedFriendId = friendId;
    });
  }

  void _proceedToMission() {
    if (selectedFriendId == null) {
      _showError('먼저 친구를 선택해주세요.');
      return;
    }
    if (myUserId == null) {
      _showError("내 ID를 불러올 수 없습니다.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionCreateScreen(
          isAIMission: false,
          isFriendMission: true,
          friendId: selectedFriendId!,              // u2_id
          authenticationAuthority: myUserId,        // 내 ID
          initialTitle: widget.initialTitle ?? '',
          initialCategory: widget.initialCategory,
          initialMessage: '',
          isFromCreateWithFriend: true,             // 출처 플래그
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구와 미션 생성'),
        backgroundColor: blue,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '같이할 친구 고르기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (selectedFriendId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: blue.shade50,
                  border: Border.all(color: blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '선택된 친구: $selectedFriendId',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: blue,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : friends.isEmpty
                  ? const Center(child: Text('친구가 없습니다.'))
                  : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friendId = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: blue.shade100,
                      child: Text(friendId[0]),
                    ),
                    title: Text(friendId),
                    trailing: selectedFriendId == friendId
                        ? const Icon(Icons.check, color: blue)
                        : null,
                    onTap: () => _selectFriend(friendId),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToMission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '미션 생성',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}