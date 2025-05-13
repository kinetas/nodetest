import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ScreenMain.dart';
import '../../SessionTokenManager.dart';
import 'SignUpScreen.dart';
import 'FindAccountScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _autoLogin = false;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    print("🔍 자동 로그인 체크 시작");
    final isLoggedIn = await SessionTokenManager.isLoggedIn();
    print("✅ 자동 로그인 여부: $isLoggedIn");

    if (isLoggedIn) {
      print("🚀 자동 로그인 → MainScreen 이동");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _passwordController.text.trim();

    print("📥 입력된 ID: '$id', PW: '${'*' * pw.length}'");

    if (id.isEmpty || pw.isEmpty) {
      setState(() {
        _resultMessage = '아이디와 비밀번호를 입력하세요.';
      });
      print("❌ 입력값 부족");
      return;
    }

    try {
      print("📡 로그인 요청 시작...");
      final response = await http.post(
        Uri.parse('http://27.113.11.48:3000/auth/keycloak-direct-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': id,
          'password': pw,
        }),
      );
      print("📨 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📦 응답 데이터: $data");

        if (data['success'] == true) {
          final jwtToken = data['jwtToken'];
          print("🪪 JWT 토큰 수신: $jwtToken");

          await SessionTokenManager.saveToken(jwtToken);
          print("✅ JWT 저장 완료");

          print("🚀 MainScreen으로 이동");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          final msg = data['message'] ?? '로그인 실패';
          setState(() {
            _resultMessage = msg;
          });
          print("❌ 로그인 실패: $msg");
        }
      } else {
        setState(() {
          _resultMessage = '서버 오류: ${response.statusCode}';
        });
        print("❌ 서버 오류");
      }
    } catch (e) {
      setState(() {
        _resultMessage = '에러 발생: $e';
      });
      print("❌ 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.lightBlue[50]!;
    final Color buttonColor = Colors.lightBlueAccent;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("로그인"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: "아이디",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _autoLogin,
                    onChanged: (bool? value) {
                      setState(() {
                        _autoLogin = value ?? false;
                      });
                    },
                  ),
                  Text("자동 로그인"),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "로그인",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text("회원가입", style: TextStyle(color: primaryColor)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindAccountScreen()),
                    );
                  },
                  child: Text("아이디/비밀번호 찾기", style: TextStyle(color: primaryColor)),
                ),
              ),
              if (_resultMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      _resultMessage,
                      style: TextStyle(
                        color: _resultMessage.contains('성공') ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}