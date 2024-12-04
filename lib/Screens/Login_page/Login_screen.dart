import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SignUp_screen.dart';
import 'findAccount_screen.dart';
import '../ScreenMain.dart';
import '../../SessionCookieManager.dart';

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
    final sessionCookie = await SessionCookieManager.getSessionCookie();
    if (sessionCookie != null) {
      _attemptLoginWithSession(sessionCookie);
    }
  }

  Future<void> _attemptLoginWithSession(String sessionCookie) async {
    // 기존 세션으로 로그인
  }

  Future<void> _attemptLogin() async {
    final String u_id = _idController.text;
    final String u_password = _passwordController.text;

    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
        Uri.parse('http://54.180.54.31:3000/api/auth/login'),
        headers: headers,
        body: jsonEncode({'u_id': u_id, 'u_password': u_password}),
      );

      if (response.statusCode == 200) {
        final authCookie = response.headers['set-cookie'];
        if (authCookie != null) {
          await SessionCookieManager.saveSessionCookie(authCookie);
          setState(() {
            _resultMessage = '로그인 성공!';
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        _showErrorDialog('로그인 실패: 서버에서 인증을 거부했습니다.');
      }
    } catch (e) {
      _showErrorDialog('네트워크 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그인 오류"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
                  onPressed: _attemptLogin,
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
                  child: Text(
                    "회원가입",
                    style: TextStyle(color: primaryColor),
                  ),
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
                  child: Text(
                    "아이디/비밀번호 찾기",
                    style: TextStyle(color: primaryColor),
                  ),
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