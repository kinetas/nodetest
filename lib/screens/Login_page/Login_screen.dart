import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUp_screen.dart';
import 'findAccount_screen.dart';
import '../ScreenMain.dart';


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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool autoLogin = prefs.getBool('autoLogin') ?? false; // 자동 로그인 여부 확인
    String? savedId = prefs.getString('savedId');
    String? savedPassword = prefs.getString('savedPassword');

    print("AutoLogin Check: autoLogin=$autoLogin, savedId=$savedId, savedPassword=$savedPassword");

    if (autoLogin && savedId != null && savedPassword != null) {
      _attemptLogin(savedId, savedPassword); // 저장된 정보로 로그인 시도
    } else {
      setState(() {
        _resultMessage = ''; // 자동 로그인 정보 없음
      });
    }
  }


  Future<void> _attemptLogin([String? savedId, String? savedPassword]) async {
    final String u_id = savedId ?? _idController.text;
    final String u_password = savedPassword ?? _passwordController.text;
    print("Attempting Login: u_id=$u_id, u_password=$u_password"); // 디버깅 메시지 추가

    final cookie = 'sessionId=abc123;';
    final headers = {'Content-Type': 'application/json', 'Cookie': cookie,};
    final response = await http.post(
      Uri.parse('http://13.124.126.234:3000/api/auth/login'),
      headers: headers,
      body: jsonEncode({'u_id': u_id, 'u_password': u_password}),
    );



    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final authCookie = response.headers['set-cookie'];

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['message'] as String? ?? '알 수 없는 오류 발생';

      if (message == 'Login successful') {
        setState(() {
          _resultMessage = '서버 연결 성공! 로그인 성공!';
        });
        if (_autoLogin) {
          _saveLoginInfo(u_id, u_password); // 자동 로그인 정보 저장
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _resultMessage = message;
        });
        _showErrorDialog('아이디 또는 비밀번호가 올바르지 않습니다.');
      }
    } else {
      setState(() {
        _resultMessage = '서버 연결 성공! 그러나 로그인 실패: ${response.statusCode}';
      });
      _showErrorDialog('서버와의 연결에 실패했습니다.');
    }


    try {

    } catch (e) {
      setState(() {
        _resultMessage = '서버 연결 실패! 네트워크 오류 발생: $e';
      });
      _showErrorDialog('네트워크 오류가 발생했습니다.');
      print('Error: $e');
    }
  }

  Future<void> _saveLoginInfo(String id, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLogin', _autoLogin);
    prefs.setString('savedId', id);
    prefs.setString('savedPassword', password);
    // 디버깅 메시지 추가
    print("Login Info Saved: autoLogin=$_autoLogin, id=$id, password=$password");

  }

  Future<void> _clearLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('autoLogin');
    prefs.remove('savedId');
    prefs.remove('savedPassword');
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