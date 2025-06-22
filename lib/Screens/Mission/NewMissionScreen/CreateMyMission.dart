import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../SessionTokenManager.dart';
import '../../../UserInfo/UserInfo_Id.dart'; // ✅ UserInfoAll → UserInfo_Id로 변경
import 'CreateMissionScreen.dart';

class CreateMyMission extends StatefulWidget {
  final bool authByFriend;
  final String? initialTitle;
  final String? initialCategory;

  const CreateMyMission({
    super.key,
    required this.authByFriend,
    this.initialTitle,
    this.initialCategory,
  });

  @override
  State<CreateMyMission> createState() => _CreateMyMissionState();
}

class _CreateMyMissionState extends State<CreateMyMission> {
  List<String> friends = [];
  String? selectedFriendId;
  String? myUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userId = await UserInfoId().fetchUserId(); // ✅ 내 ID만 가져오기
    if (userId == null) {
      _showError("내 정보를 불러올 수 없습니다.");
      setState(() => isLoading = false);
      return;
    }
    myUserId = userId;

    if (widget.authByFriend) {
      await _fetchFriends();
    } else {
      setState(() => isLoading = false);
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
    if (widget.authByFriend && selectedFriendId == null) {
      _showError('친구를 선택해주세요.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionCreateScreen(
          isAIMission: widget.initialTitle != null,
          isFriendMission: false,
          friendId: null,
          authenticationAuthority: widget.authByFriend ? selectedFriendId : null,
          // 커뮤니티 인증일 경우 authenticationAuthority는 null
          initialTitle: widget.initialTitle,
          initialCategory: widget.initialCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Colors.lightBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('혼자 미션 생성'),
        backgroundColor: blue,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.authByFriend)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    "인증: 커뮤니티 미션 인증 투표글",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: blue.shade50,
                      border: Border.all(color: blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '해당 미션을 생성하면 인증 시 커뮤니티 미션투표에 글이 작성됩니다!',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            if (widget.authByFriend) ...[
              const Text(
                '인증받을 친구 고르기',
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
            ],
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