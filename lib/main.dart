import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:capstone_1_project/SessionTokenManager.dart';
import 'package:capstone_1_project/UserInfo/UserInfo_Id.dart';
import 'firebase_options.dart';
import 'screens/Login_page/StartLogin_screen.dart';
import 'screens/ScreenMain.dart';
import 'screens/Login_page/FindAccountScreen.dart';

import 'WebRTC/NewWebRTC/RingScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleFCMClick(initialMessage);
  }

  runApp(MyApp());
}
void _handleFCMClick(RemoteMessage message) {
  final data = message.data;
  final type = data['type'] ?? 'chat';

  if (type == 'call' || type == 'incoming_call') {
    final fromId = data['fromId'] ?? 'unknown';
    final toId = data['toId'] ?? 'unknown';

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RingScreen(
          callerId: fromId,
          myId: toId,
        ),
      ),
    );
  }
}

void _sendSignalingMessage(String type, String from, String to) async {
  final token = await SessionTokenManager.getToken();
  if (token == null) return;

  final channel = WebSocketChannel.connect(Uri.parse('ws://:3005'));

  final authMessage = {
    'type': 'auth',
    'token': token,
  };
  channel.sink.add(json.encode(authMessage));

  final message = {
    'type': type,
    'from': from,
    'to': to,
  };

  Future.delayed(Duration(milliseconds: 500), () {
    channel.sink.add(json.encode(message));
    channel.sink.close();
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
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
    _setupFCM();
  }

  void _setupFCM() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📲 디바이스 토큰: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title ?? '알림',
          message.notification!.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel_id', '기본 채널',
              channelDescription: '기본 푸시 알림 채널',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }

      final data = message.data;
      final type = data['type'] ?? 'chat';

      if (type == 'call' || type == 'incoming_call') {
        final fromId = data['fromId'] ?? 'unknown';
        final toId = data['toId'] ?? 'unknown';

        if (navigatorKey.currentContext != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => RingScreen(
                callerId: fromId,
                myId: toId,
              ),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMClick);
  }

  Future<void> _checkJwtStatus() async {
    final isValid = await SessionTokenManager.isLoggedIn();
    setState(() {
      _isLoggedIn = isValid;
      _checkedLogin = true;
    });

    if (!isValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("다시 로그인 해주세요!")),
        );
      });
      await SessionTokenManager.clearToken();
    }
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) _processUri(uri);
    } catch (e) {
      print('❌ 초기 URI 오류: $e');
    }
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) _processUri(uri);
    }, onError: (err) {
      print('❌ 실시간 URI 오류: $err');
    });
  }

  void _processUri(Uri uri) async {
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      final accessToken = params['access_token'];
      if (accessToken != null) {
        final jwtRes = await http.get(
          Uri.parse("http://13.125.65.151:3000/nodetest/api/auth/issueJwtFromKeycloak"),
          headers: {"Authorization": "Bearer $accessToken"},
        );
        if (jwtRes.statusCode == 200) {
          final jwtToken = json.decode(jwtRes.body)['token'];
          await SessionTokenManager.saveToken(jwtToken);
          if (mounted && !_deepLinked) {
            setState(() {
              _deepLinked = true;
              _isLoggedIn = true;
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
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
      return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('en', 'US'), Locale('ko', 'KR')],
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