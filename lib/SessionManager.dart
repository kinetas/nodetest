import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  String? sessionId;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  // 세션 저장
  Future<void> saveSession(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
    this.sessionId = sessionId;
    print("Session saved: $sessionId");
  }

  // 세션 가져오기
  Future<String?> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }

  // 세션 삭제
  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    this.sessionId = null;
    print("Session cleared");
  }
}