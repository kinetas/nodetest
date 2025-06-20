import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../SessionCookieManager.dart'; // 세션 쿠키 매니저
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
                        items: List.generate(
                          100,
                              (index) => DateTime.now().year - index,
                        ).map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              '$year년',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
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
                        items: List.generate(12, (index) => index + 1).map((month) {
                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text(
                              '$month월',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
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
                        todayDecoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month', // Month 형식만 유지
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

    // 정규식 패턴
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final userIdRegex = RegExp(r'^.{4,}$'); // 최소 4자리 이상
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    // 비밀번호 확인
    if (password != confirmPassword) {
      _showDialog('오류', '비밀번호가 일치하지 않습니다.');
      return;
    }

    // 입력 값 검증
    if (userId.isEmpty || password.isEmpty || nickname.isEmpty || name.isEmpty || birthdate.isEmpty || email.isEmpty) {
      _showDialog('오류', '모든 필드를 입력해주세요.');
      return;
    }

    // 이메일 형식 검증
    if (!emailRegex.hasMatch(email)) {
      _showDialog('오류', '올바른 이메일 형식이 아닙니다.');
      return;
    }

    // 아이디 검증 (최소 4자리 이상)
    if (!userIdRegex.hasMatch(userId)) {
      _showDialog('오류', '아이디는 최소 4자리 이상이어야 합니다.');
      return;
    }

    // 비밀번호 검증 (영어, 숫자, 특수문자 포함 최소 8자리 이상)
    if (!passwordRegex.hasMatch(password)) {
      _showDialog('오류', '비밀번호는 영어, 숫자, 특수문자를 포함해 최소 8자리 이상이어야 합니다.');
      return;
    }

    // 서버로 데이터 전송
    final signUpData = {
      "u_id": userId,
      "u_password": password,
      "u_nickname": nickname,
      "u_name": name,
      "u_birth": birthdate,
      "u_mail": email,
    };

    try {
      final response = await SessionCookieManager.post(
        'http://27.113.11.48:3000/auth/api/auth/register-keycloak-direct', // 회원가입 API 경로
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signUpData),
      );

      // 응답 상태 코드 처리
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final message = responseData['message']?.toString() ?? '응답 메시지 없음';

        print('[✅ 회원가입 응답 성공] $message');

        if (message.contains("회원가입이 완료되었습니다")) {
          print('[✅ 회원가입 성공] $message');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('회원가입 완료'),
              content: Text('회원가입이 완료되었습니다!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => StartLoginScreen()),
                          (route) => false, // 모든 이전 화면 제거
                    );
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          );
        } else {
          // message는 있지만 실패한 경우
          String errorMsg;
          try {
            final errorData = json.decode(response.body);
            errorMsg = errorData['message']?.toString() ?? '알 수 없는 오류가 발생했습니다.';
          } catch (e) {
            errorMsg = response.body.toString();
          }

          print('[⚠️ 회원가입 실패 메시지] $errorMsg');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('회원가입 실패'),
              content: Text(errorMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('확인'),
                ),
              ],
            ),
          );
        }
      } else {
        // HTTP 상태코드가 200/201 이외인 경우
        String errorMsg;
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['message']?.toString() ?? '알 수 없는 오류가 발생했습니다.';
        } catch (e) {
          errorMsg = response.body.toString();
        }

        print('[❌ 회원가입 실패 응답] statusCode: ${response.statusCode}, body: ${response.body}');

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('회원가입 실패'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('[🔥 예외 발생] $e');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('네트워크 오류'),
          content: Text('회원가입 중 문제가 발생했습니다.\n\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
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

// 회원가입 성공 시 StartLogin으로 리다이렉션
  void _showDialogWithRedirect(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StartLoginScreen()),
              ); // StartLoginScreen으로 이동
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