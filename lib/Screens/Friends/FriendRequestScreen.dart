import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ JWT 기반 세션 토큰 매니저 사용

class FriendRequestScreen extends StatefulWidget {
  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  List<String> receivedRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReceivedRequests();
  }

  Future<void> _fetchReceivedRequests() async {
    print("📡 [GET] 친구 요청 목록 요청 중...");
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/nodetest/dashboard/friends/tfriends',
      );

      print("📦 [Fetch Response] ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          receivedRequests = List<String>.from(responseData['receivedRequests'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnack('받은 요청 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack('네트워크 오류: $e');
    }
  }

  Future<void> _handleRequest(String friendId, bool accept) async {
    final token = await SessionTokenManager.getToken();
    final url = accept
        ? 'http://27.113.11.48:3000/nodetest/dashboard/friends/accept'
        : 'http://27.113.11.48:3000/nodetest/dashboard/friends/reject';

    print("📤 [POST] $url with f_id=$friendId");

    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'f_id': friendId}),
      );

      print("📦 [POST 응답] ${response.statusCode} ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          receivedRequests.remove(friendId);
        });
        _showSnack(responseData['message'] ?? '요청 처리 성공');
      } else {
        _showSnack(responseData['message'] ?? '요청 처리 실패');
      }
    } catch (e) {
      _showSnack('네트워크 오류: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('받은 친구 요청')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : receivedRequests.isEmpty
          ? Center(child: Text('받은 요청이 없습니다.'))
          : ListView.builder(
        itemCount: receivedRequests.length,
        itemBuilder: (context, index) {
          final friendId = receivedRequests[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(child: Text(friendId[0])),
              title: Text('요청 ID: $friendId'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _handleRequest(friendId, true),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _handleRequest(friendId, false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}