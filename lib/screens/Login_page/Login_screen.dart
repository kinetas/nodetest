import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
    _checkAutoLogin(); // 자동 로그인 체크
  }
  Future<void> _checkAutoLogin() async {
    final sessionCookie = await SessionCookieManager.getSessionCookie();
    if (sessionCookie != null) {
      print("AutoLogin Check: sessionCookie=$sessionCookie");
      _attemptLoginWithSession(sessionCookie); // 세션 쿠키로 로그인 시도
    } else {
      setState(() {
        _resultMessage = ''; // 자동 로그인 정보 없음
      });
    }
  }

  Future<void> _attemptLoginWithSession(String sessionCookie) async {
    try {
      final headers = {'Cookie': sessionCookie};
      final response = await http.get(
        Uri.parse('http://54.180.54.31:3000/api/auth/validate-session'),
        headers: headers,
      );

      print('Session Validation Response status: ${response.statusCode}');
      print('Session Validation Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _resultMessage = '자동 로그인 성공!';
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _resultMessage = '자동 로그인 실패: 세션 만료';
        });
        _showErrorDialog('세션이 만료되었습니다. 다시 로그인해주세요.');
      }
    } catch (e) {
      setState(() {
        _resultMessage = '자동 로그인 실패: 네트워크 오류 발생';
      });
      print('Error during session validation: $e');
    }
  }


  Future<void> _attemptLogin() async {
    final String u_id = _idController.text;
    final String u_password = _passwordController.text;

    print("Attempting Login: u_id=$u_id, u_password=$u_password");

    try {
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
        Uri.parse('http://54.180.54.31:3000/api/auth/login'),
        headers: headers,
        body: jsonEncode({'u_id': u_id, 'u_password': u_password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final authCookie = response.headers['set-cookie'];
        if (authCookie != null) {
          await _saveSessionCookie(authCookie); // 세션 쿠키 저장
          setState(() {
            _resultMessage = '로그인 성공!';
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          _showErrorDialog('세션 쿠키를 가져올 수 없습니다.');
        }
      } else {
        setState(() {
          _resultMessage = '로그인 실패: ${response.statusCode}';
        });
        _showErrorDialog('로그인 실패: 서버에서 인증을 거부했습니다.');
      }
    } catch (e) {
      setState(() {
        _resultMessage = '로그인 실패: 네트워크 오류 발생';
      });
      _showErrorDialog('네트워크 오류가 발생했습니다.');
      print('Error: $e');
    }
  }

  

  Future<void> _saveSessionCookie(String cookie) async {
    await SessionCookieManager.saveSessionCookie(cookie);
    print("Auth Cookie Saved: $cookie");
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Center(
              child: Image.asset(
                'assets/logo.png', // 로고 파일 경로 설정
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "아이디"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
              children: [
                Text(
                  "아직 아이디가 없으신가요?",
                  style: TextStyle(fontSize: 14), // 텍스트 스타일
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text(
                    "회원가입",
                    style: TextStyle(color: Colors.blue, fontSize: 14), // 버튼 스타일
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _attemptLogin(); // 로그인 시도
                },
                child: Text("로그인"),
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
    );
  }
}