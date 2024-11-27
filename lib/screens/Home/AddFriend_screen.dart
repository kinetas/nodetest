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
  bool isLoading = false;
  String? sessionCookie; // 세션 쿠키 저장

  @override
  void initState() {
    super.initState();
    _initializeSession(); // 세션 초기화
  }

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
        Uri.parse("http://54.180.54.31:3000/dashboard/friends/request"),
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