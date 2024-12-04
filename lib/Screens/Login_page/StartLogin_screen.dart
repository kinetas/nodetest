import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'signUp_screen.dart';
import 'Login_screen.dart';
import 'findAccount_screen.dart';
import '../ScreenMain.dart'; // Update the path if necessary

class StartLoginScreen extends StatelessWidget {
  const StartLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final primaryColor = Colors.blue[800];
          final buttonColor = Colors.lightBlueAccent;

          return Column(
            children: [
              SizedBox(height: screenHeight * 0.3),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  },
                  child: Text(
                    '밥 먹었니?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '로그인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindAccountScreen()),
                  );
                },
                child: Text(
                  '아이디/비밀번호 찾기',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://www.instagram.com/hav_eyoueat_en/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    print('Could not launch $url');
                  }
                },
                child: Text(
                  'Instagram',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}