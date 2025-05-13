import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController friendIdController = TextEditingController();
  List<String> sentRequests = [];
  bool isLoading = false;
  bool isLoadingRequests = true;

  @override
  void initState() {
    super.initState();
    print("🔵 initState 호출됨 - 로그인 상태 확인 및 데이터 가져오기");
    _checkLoginAndFetchData();
  }

  Future<void> _checkLoginAndFetchData() async {
    final isLoggedIn = await SessionTokenManager.isLoggedIn();
    print("🔍 로그인 상태 확인: $isLoggedIn");
    if (!isLoggedIn) {
      _redirectToLogin();
      return;
    }
    await _fetchSentRequests();
  }

  void _redirectToLogin() {
    print("❗️로그인되지 않음 - 로그인 화면으로 이동");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("로그인이 필요합니다.")),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _fetchSentRequests() async {
    try {
      print("📤 보낸 요청 목록 API 호출 시작...");
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/dashboard/friends/tfriends',
      );
      print("📥 응답 수신: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📦 응답 데이터: $data");
        setState(() {
          sentRequests = List<String>.from(data['sentRequests'] ?? []);
          isLoadingRequests = false;
        });
      } else {
        print("❌ 요청 실패 상태 코드: ${response.statusCode}");
        _showSnack('보낸 요청 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      print("🚨 요청 중 오류 발생: $e");
      _showSnack('네트워크 오류: $e');
    }
  }

  Future<void> sendFriendRequest() async {
    final token = await SessionTokenManager.getToken();
    print("🔐 토큰 확인: $token");

    final friendId = friendIdController.text.trim();
    print("📝 입력된 친구 ID: $friendId");

    if (friendId.isEmpty) {
      _showSnack("친구 ID를 입력하세요.");
      return;
    }

    setState(() => isLoading = true);

    try {
      print("📤 친구 요청 전송 중...");
      final response = await SessionTokenManager.post(
        "http://27.113.11.48:3000/dashboard/friends/request",
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"f_id": friendId}),
      );

      print("📥 응답 수신: ${response.statusCode}");
      final responseData = jsonDecode(response.body);
      print("📦 응답 데이터: $responseData");

      if (response.statusCode == 200 && responseData['success'] == true) {
        print("✅ 요청 성공");
        _showSnack("친구 요청이 전송되었습니다.");
        setState(() => sentRequests.add(friendId));
        friendIdController.clear();
      } else {
        print("❌ 요청 실패 - 메시지: ${responseData['message']}");
        _showSnack(responseData['message'] ?? "친구 요청 실패");
      }
    } catch (e) {
      print("🚨 오류 발생: $e");
      _showSnack("오류 발생: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    print("📣 메시지 표시: $message");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('친구 추가 및 보낸 요청')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: friendIdController,
              decoration: InputDecoration(labelText: "친구 ID", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: sendFriendRequest, child: Text("친구 요청 보내기")),
            SizedBox(height: 30),
            Divider(),
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
                      leading: CircleAvatar(child: Text(friendId[0])),
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