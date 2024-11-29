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
    // 기존 코드 유지
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
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.lightBlue[50]!;
    final Color buttonColor = Colors.lightBlueAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('이름', _nameController, primaryColor),
              _buildTextField('닉네임', _nicknameController, primaryColor),
              _buildTextField('이메일', _emailController, primaryColor, keyboardType: TextInputType.emailAddress),
              _buildDateField('생년월일 (0000-00-00)', _birthdateController, context, primaryColor),
              _buildTextField('USER ID', _userIdController, primaryColor),
              _buildTextField('비밀번호', _passwordController, primaryColor, obscureText: true),
              _buildTextField('비밀번호 재입력', _confirmPasswordController, primaryColor, obscureText: true),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Color primaryColor,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor),
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
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor),
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
          suffixIcon: Icon(Icons.calendar_today, color: primaryColor),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}