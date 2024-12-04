import 'package:flutter/material.dart';
import 'FriendClick.dart'; // FriendClick 팝업 위젯

class FriendSearchDialog extends StatefulWidget {
  final List<String> friends; // 전달받은 친구 목록

  const FriendSearchDialog({required this.friends});

  @override
  _FriendSearchDialogState createState() => _FriendSearchDialogState();
}

class _FriendSearchDialogState extends State<FriendSearchDialog> {
  TextEditingController _searchController = TextEditingController();
  List<String> filteredFriends = []; // 검색된 친구 목록

  // 친구 검색
  void _searchFriend() {
    String searchQuery = _searchController.text.trim();
    setState(() {
      if (searchQuery.isEmpty) {
        filteredFriends = [];
      } else {
        filteredFriends = widget.friends
            .where((friend) => friend.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 검색 입력 필드
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '친구 ID 입력',
                hintText: '검색할 친구의 ID를 입력하세요',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchFriend,
                ),
              ),
            ),
            SizedBox(height: 16),
            // 검색 결과 표시
            Expanded(
              child: filteredFriends.isEmpty && _searchController.text.isNotEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friendId = filteredFriends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(friendId[0]), // ID의 첫 글자 표시
                    ),
                    title: Text('친구 ID: $friendId'),
                    onTap: () {
                      Navigator.pop(context); // 팝업 닫기
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // 컨트롤러 정리
    super.dispose();
  }
}