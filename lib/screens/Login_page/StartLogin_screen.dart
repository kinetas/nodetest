// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'signUp_screen.dart';
// import 'Login_screen.dart';
// import 'findAccount_screen.dart';
//
// class StartLoginScreen extends StatelessWidget {
//   const StartLoginScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue[50],
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final screenHeight = constraints.maxHeight;
//           return Column(
//             children: [
//               SizedBox(height: screenHeight * 0.33),
//               Center(
//                 child: Text(
//                   '밥 먹었니?',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue[800],
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.33 - 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[700],
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text('로그인', style: TextStyle(fontSize: 16)),
//                   ),
//                   SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SignUpScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[700],
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text('회원가입', style: TextStyle(fontSize: 16)),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => FindAccountScreen()),
//                   );
//                 },
//                 child: Text(
//                   '아이디/비밀번호 찾기',
//                   style: TextStyle(color: Colors.blue[700], fontSize: 14),
//                 ),
//               ),
//               Spacer(),
//               GestureDetector(
//                 onTap: () async {
//                   final url = Uri.parse('https://www.instagram.com/');
//                   if (await canLaunchUrl(url)) {
//                     await launchUrl(url, mode: LaunchMode.externalApplication);
//                   } else {
//                     print('Could not launch $url');
//                   }
//                 },
//                 child: Text(
//                   'Instagram',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     decoration: TextDecoration.underline,
//                     color: Colors.blue[700],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

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
          return Column(
            children: [
              SizedBox(height: screenHeight * 0.33),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()), // Replace the current screen
                    );
                  },
                  child: Text(
                    '밥 먹었니?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.33 - 40),
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
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('로그인', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('회원가입', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindAccountScreen()),
                  );
                },
                child: Text(
                  '아이디/비밀번호 찾기',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: Colors.blue[700],
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