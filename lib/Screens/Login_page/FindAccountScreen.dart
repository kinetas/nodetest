import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'LoginScreen.dart'; // LoginScreen.dart 경로 확인
import 'FindPasswordScreen.dart'; // FindPasswordScreen.dart 경로 확인

class FindAccountScreen extends StatefulWidget {
  @override
  _FindAccountScreenState createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

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

  Future<void> _findUserId() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final birthdate = _birthdateController.text.trim();

    if (name.isEmpty || nickname.isEmpty || email.isEmpty || birthdate.isEmpty) {
      _showErrorMessage('모든 필드를 입력해주세요.');
      return;
    }

    final url = Uri.parse('http://54.180.54.31:3000/api/auth/findUid');
    final body = {
      "name": name,
      "nickname": nickname,
      "birthdate": birthdate,
      "email": email
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userId = responseData['userId'];
        _showUserIdMessage(userId);
      } else {
        _showErrorMessage('아이디를 찾을 수 없습니다.');
      }
    } catch (e) {
      _showErrorMessage('오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _showUserIdMessage(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('아이디 찾기'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Text('사용자 아이디는 "$userId" 입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('로그인'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;
    final Color backgroundColor = Colors.lightBlue[50]!;
    final Color buttonColor = Colors.lightBlueAccent;

    return Scaffold(
      appBar: AppBar(
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
                '아이디 찾기',
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
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _findUserId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                    );
                  },
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(color: primaryColor),
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
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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