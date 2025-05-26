import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:convert';
import 'package:capstone_1_project/SessionTokenManager.dart';
import 'screens/Login_page/StartLogin_screen.dart';
import 'screens/ScreenMain.dart';
import 'screens/Login_page/FindAccountScreen.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _checkedLogin = false;
  bool _deepLinked = false;
  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _checkJwtStatus();
    _initDeepLinks();
  }

  Future<void> _checkJwtStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      _isLoggedIn = token != null;
      _checkedLogin = true;
    });
    print("✅ 로그인 체크 결과: $_isLoggedIn");
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        print('📥 초기 딥링크 URI: $uri');
        _processUri(uri);
      }
    } catch (e) {
      print('❌ 초기 URI 처리 오류: $e');
    }

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('📥 실시간 딥링크 URI: $uri');
        _processUri(uri);
      }
    }, onError: (err) {
      print('❌ 실시간 URI 처리 오류: $err');
    });
  }

  void _processUri(Uri uri) async {
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      final accessToken = params['access_token'];
      if (accessToken != null) {
        print('✅ access_token 수신: $accessToken');

        final jwtRes = await http.get(
          Uri.parse("http://27.113.11.48:3000/nodetest/api/auth/issueJwtFromKeycloak"),
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        );

        if (jwtRes.statusCode == 200) {
          final jwtToken = json.decode(jwtRes.body)['token'];
          await SessionTokenManager.saveToken(jwtToken);
          print("✅ JWT 저장 완료");

          if (mounted && !_deepLinked) {
            setState(() {
              _deepLinked = true;
              _isLoggedIn = true;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } else {
          print("❌ JWT 발급 실패: ${jwtRes.statusCode}");
        }
      } else {
        print("❌ URI에 access_token 없음");
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedLogin) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _isLoggedIn ? MainScreen() : StartLoginScreen(),
      routes: {
        '/dashboard': (context) => MainScreen(),
        '/find_account': (context) => FindAccountScreen(),
      },
    );
  }
}
