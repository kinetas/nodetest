import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저 임포트

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController friendIdController = TextEditingController();
  List<String> sentRequests = []; // 보낸 요청 목록
  bool isLoading = false; // 요청 중 상태
  bool isLoadingRequests = true; // 보낸 요청 목록 로딩 상태
  String? sessionCookie; // 세션 쿠키 저장

  @override
  void initState() {
    super.initState();
    _initializeSession(); // 세션 초기화
    _fetchSentRequests(); // 보낸 요청 목록 가져오기
  }

  // 세션 초기화
  Future<void> _initializeSession() async {
    sessionCookie = await SessionCookieManager.getSessionCookie(); // 세션 쿠키 가져오기
    if (sessionCookie == null) {
      print("Session is invalid. Redirecting to login.");
      _redirectToLogin();
    } else {
      print("Session initialized: $sessionCookie");
    }
  }

  void _redirectToLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("세션이 유효하지 않습니다. 다시 로그인 해주세요.")),
    );
    Navigator.pushReplacementNamed(context, '/login'); // 로그인 화면으로 리디렉션
  }

  // 보낸 요청 목록 가져오기
  Future<void> _fetchSentRequests() async {
    try {
      final response = await SessionCookieManager.get(
        'http://27.113.11.48:3000/dashboard/friends/tfriends',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          sentRequests = responseData['sentRequests'] != null
              ? List<String>.from(responseData['sentRequests'])
              : [];
          isLoadingRequests = false;
        });
      } else {
        setState(() => isLoadingRequests = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('보낸 요청 목록을 가져오는데 실패했습니다.')),
        );
      }
    } catch (e) {
      setState(() => isLoadingRequests = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  // 친구 요청 보내기
  Future<void> sendFriendRequest() async {
    if (sessionCookie == null) {
      _redirectToLogin();
      return;
    }

    final String friendId = friendIdController.text.trim();
    if (friendId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("친구의 ID를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': sessionCookie!,
    };

    try {
      final response = await http.post(
        Uri.parse("http://27.113.11.48:3000/dashboard/friends/request"),
        headers: headers,
        body: jsonEncode({"f_id": friendId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("친구 요청이 성공적으로 전송되었습니다.")),
        );
        setState(() {
          sentRequests.add(friendId); // 보낸 요청 목록에 추가
        });
        friendIdController.clear();
      } else {
        final errorMessage = responseData['message'] ?? "친구 요청을 보낼 수 없습니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $error")),
      );
      print("Error during friend request: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 추가 및 보낸 요청'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 친구 요청 보내기 입력 필드 및 버튼
            TextField(
              controller: friendIdController,
              decoration: InputDecoration(
                labelText: "친구 ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: sendFriendRequest,
              child: Text("친구 요청 보내기"),
            ),
            SizedBox(height: 30),
            Divider(),
            // 보낸 요청 목록 표시
            Expanded(
              child: isLoadingRequests
                  ? Center(child: CircularProgressIndicator())
                  : sentRequests.isEmpty
                  ? Center(child: Text('보낸 요청이 없습니다.'))
                  : ListView.builder(
                itemCount: sentRequests.length,
                itemBuilder: (context, index) {
                  final friendId = sentRequests[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(friendId[0]), // 요청 ID 첫 글자
                      ),
                      title: Text('요청 ID: $friendId'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}