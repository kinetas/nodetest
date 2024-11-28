import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//쿠키 값 받아오는 클래스 shared_preferences.dart를 통해서 로컬에도 저장하는 클래스
class SessionCookieManager {
  static const String _cookieKey = 'sessionCookie';

  // 세션 쿠키 저장
  static Future<void> saveSessionCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookie);
    print("Session Cookie Saved: $cookie");
  }

  // 세션 쿠키 불러오기
  static Future<String?> getSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  // 세션 쿠키 삭제
  static Future<void> clearSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    print("Session Cookie Cleared");
  }

  // HTTP GET 요청
  static Future<http.Response> get(String url) async {
    String? cookie = await getSessionCookie();
    final response = await http.get(
      Uri.parse(url),
      headers: cookie != null ? {'Cookie': cookie} : {},
    );

    if (response.headers['set-cookie'] != null) {
      await saveSessionCookie(response.headers['set-cookie']!);
    }

    return response;
  }

  // HTTP POST 요청
  static Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    String? cookie = await getSessionCookie();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        if (cookie != null) 'Cookie': cookie,
        if (headers != null) ...headers,
      },
      body: body,
    );

    if (response.headers['set-cookie'] != null) {
      await saveSessionCookie(response.headers['set-cookie']!);
    }

    return response;
  }
}