import 'package:shared_preferences/shared_preferences.dart';

class SessionCookieManager {
  static const String _cookieKey = 'sessionCookie';

  /// 세션 쿠키 저장
  static Future<void> saveSessionCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookie);
    print("Session Cookie Saved: $cookie");
  }

  /// 세션 쿠키 불러오기
  static Future<String?> getSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  /// 세션 쿠키 삭제
  static Future<void> clearSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    print("Session Cookie Cleared");
  }
}