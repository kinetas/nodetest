import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  Future<void> _resetPassword(BuildContext context) async {
    final uri = Uri.parse("http://27.113.11.48:3000/auth/api/auth/changePassword");

    if (newPasswordController.text != confirmPasswordController.text) {
      _showDialog("오류", "비밀번호가 일치하지 않습니다.");
      return;
    }

    if (!passwordRegex.hasMatch(newPasswordController.text)) {
      _showDialog("오류", "비밀번호는 최소 8자, 영어, 숫자, 특수문자를 포함해야 합니다.");
      return;
    }

    try {
      final requestData = {
        "userId": userIdController.text,
        "newPassword": newPasswordController.text,
      };

      final response = await SessionCookieManager.post(
        uri.toString(),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('[📤 요청 데이터] $requestData');
      print('[📥 응답 코드] ${response.statusCode}');
      print('[📥 응답 내용] ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          _showDialog("완료", "비밀번호가 성공적으로 변경되었습니다!", goBack: true);
        } else {
          _showDialog("실패", responseData["message"]?.toString() ?? "변경에 실패했습니다.");
        }
      } else {
        _showDialog("오류", "서버 오류가 발생했습니다. (${response.statusCode})");
      }
    } catch (e) {
      print('[❌ 예외 발생] $e');
      _showDialog("오류", "비밀번호 변경 중 문제가 발생했습니다.");
    }
  }

  void _showDialog(String title, String content, {bool goBack = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              if (goBack) Navigator.pop(context); // 뒤로가기
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

    return Scaffold(
      appBar: AppBar(
        title: Text("비밀번호 재설정", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.withOpacity(0.1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset, size: 48, color: primaryColor),
                    SizedBox(height: 16),
                    Text("비밀번호 재설정", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 30),
                    _buildTextField(controller: userIdController, labelText: "아이디"),
                    SizedBox(height: 16),
                    _buildTextField(controller: newPasswordController, labelText: "새 비밀번호", obscureText: true),
                    SizedBox(height: 16),
                    _buildTextField(controller: confirmPasswordController, labelText: "비밀번호 확인", obscureText: true),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _resetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("비밀번호 변경", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}