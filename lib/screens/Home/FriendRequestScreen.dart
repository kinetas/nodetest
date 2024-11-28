import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../SessionCookieManager.dart';

// 나에게 온 친구 요청 목록을 출력해주고 수락할 수 있는 클래스
class FriendRequestScreen extends StatefulWidget {
  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  List<String> receivedRequests = []; // 받은 요청
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReceivedRequests();
  }

  // 받은 요청 가져오기
  Future<void> _fetchReceivedRequests() async {
    try {
      final response = await SessionCookieManager.get(
        'http://54.180.54.31:3000/dashboard/friends/tfriends',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          // 받은 요청 데이터 저장
          receivedRequests = responseData['receivedRequests'] != null
              ? List<String>.from(responseData['receivedRequests'])
              : [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('받은 요청 목록을 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  // 친구 요청 수락 또는 거절
  Future<void> _handleRequest(String friendId, bool accept) async {
    final url = accept
        ? 'http://54.180.54.31:3000/dashboard/friends/accept'
        : 'http://54.180.54.31:3000/dashboard/friends/reject';

    try {
      final response = await SessionCookieManager.post(
        url,
        body: json.encode({'f_id': friendId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          receivedRequests.remove(friendId); // 요청 성공 시 목록에서 제거
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? '요청 처리 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? '요청 처리 실패')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('받은 친구 요청'),
      ),
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
              leading: CircleAvatar(
                child: Text(friendId[0]), // 요청 ID 첫 글자
              ),
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