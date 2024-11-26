import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isUserIdVerified = false; // 아이디 확인 상태

  Future<void> _verifyUserId(BuildContext context) async {
    final uri = Uri.parse("http://13.124.126.234:3000/api/auth/findUid");

    try {
      final requestData = {
        "userId": userIdController.text,
      };

      print("전송 데이터: $requestData");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print("응답 상태 코드: ${response.statusCode}");
      print("응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          setState(() {
            isUserIdVerified = true; // 아이디 확인 성공
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("아이디가 확인되었습니다. 비밀번호를 변경하세요.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"] ?? "아이디를 확인할 수 없습니다.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버와의 통신에 실패했습니다. 상태 코드: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("예외 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final uri = Uri.parse("http://13.124.126.234:3000/api/auth/changePassword");

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    try {
      final requestData = {
        "userId": userIdController.text,
        "newPassword": newPasswordController.text,
      };

      print("전송 데이터: $requestData");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print("응답 상태 코드: ${response.statusCode}");
      print("응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"] ?? "비밀번호를 변경할 수 없습니다.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버와의 통신에 실패했습니다. 상태 코드: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("예외 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("비밀번호 재설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userIdController,
              decoration: InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verifyUserId(context),
              child: Text("아이디 확인"),
            ),
            if (isUserIdVerified) ...[
              SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: "새 비밀번호",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "비밀번호 확인",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _resetPassword(context),
                child: Text("비밀번호 변경"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}