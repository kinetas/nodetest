import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../SessionManager.dart'; // 세션 매니저 임포트

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController friendIdController = TextEditingController();
  bool isLoading = false;
  String? sessionId; // 세션 ID 저장

  @override
  void initState() {
    super.initState();
    _initializeSession(); // 세션 초기화
  }

  Future<void> _initializeSession() async {
    final sessionManager = SessionManager();
    sessionId = await sessionManager.getSession(); // 세션 ID 가져오기

    if (sessionId == null) {
      print("Session is invalid. Redirecting to login.");
      Navigator.pushReplacementNamed(context, '/login'); // 로그인 화면으로 리디렉션
    } else {
      print("Session initialized: $sessionId");
    }
  }

  Future<void> sendFriendRequest() async {
    /*
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("세션이 유효하지 않습니다. 다시 로그인 해주세요.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (friendId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("친구의 ID를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

     */

    final String friendId = friendIdController.text.trim();

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'connect.sid=s%3ARbcf1oQ3h5E2mVHT6ru8vBDpHW9fxhH2.x5xnHj7uGjCBduEn8xjFdzuLZdKCk1MkXWVuOEPUVQE; Path=/; HttpOnly; Expires=Wed, 20 Nov 2024 07:06:27 GMT;',
    };

    try {
      final response = await http.post(
        Uri.parse("http://13.124.126.234:3000/dashboard/friends/request"),
        headers: headers,
        body: jsonEncode({"f_id": friendId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("친구 요청이 성공적으로 전송되었습니다.")),
        );
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
        title: Text('친구 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}