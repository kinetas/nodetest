import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; // Provider 추가
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'screens/Login_page/StartLogin_screen.dart';
import 'screens/ScreenMain.dart';
import 'screens/Login_page/findAccount_screen.dart';
import 'screens/Mission/MissionProvider.dart'; // MissionProvider 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화
  final bool isLoggedIn = await checkLoginStatus(); // 로그인 상태 확인
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionProvider()), // MissionProvider 등록
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

// 로그인 상태 확인 함수
Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('savedId') != null; // 저장된 ID가 있으면 로그인 상태로 간주
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
        '/find_account': (context) => FindAccountScreen(), // FindAccountScreen 추가
      },
    );
  }
}