import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // 날짜 형식 변환을 위한 패키지

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController(); // 0000-00-00 형식
  final TextEditingController _userIdController = TextEditingController(); // USER ID
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("ko", "KR"), // 한국어 설정
    );

    if (pickedDate != null) {
      // 0000-00-00 형식으로 변환
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _birthdateController.text = formattedDate; // 텍스트 필드에 표시
      });
    }
  }

  Future<void> signUp() async {
    try {
      // 비밀번호 확인
      if (_passwordController.text != _confirmPasswordController.text) {
        _showDialog('회원가입 실패', '비밀번호가 일치하지 않습니다.');
        return;
      }

      // 필드 유효성 검사
      if (_nameController.text.isEmpty ||
          _nicknameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _birthdateController.text.isEmpty ||
          _userIdController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showDialog('회원가입 실패', '모든 필드를 채워주세요.');
        return;
      }

      // 서버로 요청 전 데이터 확인
      final requestData = {
        'u_id': _userIdController.text,
        'u_password': _passwordController.text,
        'u_nickname': _nicknameController.text,
        'u_name': _nameController.text,
        'u_birth': _birthdateController.text, // 0000-00-00 형식
        'u_mail': _emailController.text,
      };

      final url = Uri.parse('http://54.180.54.31:3000/api/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        _showDialog('회원가입 성공', '회원가입이 완료되었습니다.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? '요청이 잘못되었습니다.';
        _showDialog('회원가입 실패', errorMessage);
      } else if (response.statusCode >= 500) {
        _showDialog('회원가입 실패', '서버 오류가 발생했습니다. 다시 시도해주세요.');
      } else {
        _showDialog('회원가입 실패', '알 수 없는 오류가 발생했습니다.');
      }
    } catch (e) {
      _showDialog('회원가입 실패', '네트워크 오류가 발생했습니다. $e');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: '닉네임'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _birthdateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: '생년월일 (0000-00-00)', // 생년월일 입력 형식 안내
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context), // 달력 열기
              ),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'USER ID'), // USER ID 필드
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: '비밀번호 재입력'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}