import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'LoginScreen.dart';
import 'FindPasswordScreen.dart';

class FindAccountScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("ko", "KR"), // 한국어 설정
    );

    if (pickedDate != null) {
      // 선택한 날짜를 '0000-00-00' 형식으로 변환
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      birthdateController.text = formattedDate;
    }
  }

  Future<void> _findUserId(BuildContext context) async {
    final uri = Uri.parse("http://54.180.54.31:3000/api/auth/findUid");

    try {
      final requestData = {
        "name": nameController.text,
        "nickname": nicknameController.text,
        "birthdate": birthdateController.text,
        "email": emailController.text,
      };

      print("전송 데이터: $requestData"); // 디버깅용 로그

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print("응답 상태 코드: ${response.statusCode}"); // 디버깅용 로그
      print("응답 본문: ${response.body}"); // 디버깅용 로그

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          final userId = responseData["userId"];
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("아이디 찾기"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("찾은 아이디: $userId"),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text("로그인하기"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(),
                              ),
                            );
                          },
                          child: Text("비밀번호 찾기"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          final errorMessage = responseData["message"] ?? "입력하신 정보와 일치하는 아이디가 없습니다.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버와의 통신에 실패했습니다. 상태 코드: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("예외 발생: $e"); // 디버깅용 로그
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("아이디/비밀번호 찾기")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: "닉네임"),
            ),
            TextFormField(
              controller: birthdateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "생년월일 (0000-00-00)",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "이메일"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _findUserId(context),
              child: Text("찾기"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(),
                  ),
                );
              },
              child: Text("비밀번호 찾기"),
            ),
          ],
        ),
      ),
    );
  }
}

