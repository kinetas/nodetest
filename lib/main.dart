import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:capstone_1_project/SessionCookieManager.dart'; // 세션 쿠키 매니저 추가
import 'screens/Login_page/StartLogin_screen.dart';
import 'screens/ScreenMain.dart';
import 'screens/Login_page/FindAccountScreen.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final bool isLoggedIn = await checkLoginStatus();
  runApp(
    MyApp(isLoggedIn: isLoggedIn),
  );
}

// 세션 쿠키를 활용한 로그인 상태 확인 함수
Future<bool> checkLoginStatus() async {
  try {
    final response = await SessionCookieManager.get("http://27.113.11.48:3000/api/session/check");
    if (response.statusCode == 200) {
      // 세션이 유효한 경우 로그인 상태로 간주
      final data = json.decode(response.body);
      return data['isLoggedIn'] == true;
    }
    return false; // 세션이 유효하지 않은 경우
  } catch (e) {
    print("Error checking login status: $e");
    return false; // 에러 발생 시 로그인 상태 아님
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale('en', 'US'), // 영어
        Locale('ko', 'KR'), // 한국어
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isLoggedIn ? MainScreen() : StartLoginScreen(), // 로그인 여부에 따라 초기 화면 설정
      routes: {
        '/dashboard': (context) => MainScreen(),
        '/find_account': (context) => FindAccountScreen(),
      },
    );
  }
}