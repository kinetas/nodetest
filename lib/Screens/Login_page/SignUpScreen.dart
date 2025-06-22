import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'StartLogin_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 450,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: _focusedDate.year,
                        items: List.generate(100, (index) => DateTime.now().year - index)
                            .map((year) => DropdownMenuItem(value: year, child: Text('$year년')))
                            .toList(),
                        onChanged: (year) {
                          if (year != null) {
                            setState(() {
                              _focusedDate = DateTime(year, _focusedDate.month);
                            });
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      DropdownButton<int>(
                        value: _focusedDate.month,
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(value: month, child: Text('$month월')))
                            .toList(),
                        onChanged: (month) {
                          if (month != null) {
                            setState(() {
                              _focusedDate = DateTime(_focusedDate.year, month);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: TableCalendar(
                      firstDay: DateTime(1900),
                      lastDay: DateTime.now(),
                      focusedDay: _focusedDate,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: Colors.lightBlueAccent, shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
                      ),
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                          _focusedDate = focusedDay;
                          _birthdateController.text = DateFormat('yyyy-MM-dd').format(selectedDay);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> signUp() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();
    final name = _nameController.text.trim();
    final birthdate = _birthdateController.text.trim();
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final userIdRegex = RegExp(r'^.{4,}$');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (password != confirmPassword) {
      _showDialog('오류', '비밀번호가 일치하지 않습니다.');
      return;
    }
    if ([userId, password, nickname, name, birthdate, email].any((v) => v.isEmpty)) {
      _showDialog('오류', '모든 필드를 입력해주세요.');
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      _showDialog('오류', '올바른 이메일 형식이 아닙니다.');
      return;
    }
    if (!userIdRegex.hasMatch(userId)) {
      _showDialog('오류', '아이디는 최소 4자리 이상이어야 합니다.');
      return;
    }
    if (!passwordRegex.hasMatch(password)) {
      _showDialog('오류', '비밀번호는 영어, 숫자, 특수문자를 포함해 최소 8자리 이상이어야 합니다.');
      return;
    }

    final signUpData = {
      "u_id": userId,
      "u_password": password,
      "u_nickname": nickname,
      "u_name": name,
      "u_birth": birthdate,
      "u_mail": email,
    };

    try {
      final response = await http.post(
        Uri.parse('http://13.125.65.151:3000/auth/api/auth/register-keycloak-direct'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signUpData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = jsonDecode(response.body)['message'] ?? '응답 메시지 없음';
        if (message.contains('회원가입이 완료되었습니다')) {
          _showDialogWithRedirect('회원가입 완료', '회원가입이 완료되었습니다!');
        } else {
          _showDialog('회원가입 실패', message);
        }
      } else {
        final error = jsonDecode(response.body)['message'] ?? '알 수 없는 오류';
        _showDialog('회원가입 실패', error);
      }
    } catch (e) {
      _showDialog('네트워크 오류', '회원가입 중 문제가 발생했습니다.\n\n$e');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
      ),
    );
  }

  void _showDialogWithRedirect(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StartLoginScreen()));
            },
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
      appBar: AppBar(title: Text('회원가입'), backgroundColor: primaryColor, elevation: 0),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('회원가입', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('회원가입', style: TextStyle(fontSize: 18, color: Colors.white)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 2)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 2)),
          suffixIcon: Icon(Icons.calendar_today, color: primaryColor),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}