import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionTokenManager {
  static const _tokenKey = 'access_token';
  static String? _token;

  /// 토큰 저장
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 토큰 가져오기
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// 로그아웃: 토큰 삭제
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// GET 요청 (토큰 포함)
  static Future<http.Response> get(String url) async {
    final token = await getToken();
    print('📤 [GET] $url with Bearer $token');
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  /// POST 요청 (토큰 포함)
  static Future<http.Response> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [POST] $url');
    print('📤 Headers: $allHeaders');
    print('📤 Body: $body');
    return await http.post(Uri.parse(url), headers: allHeaders, body: body);
  }

  /// DELETE 요청 (토큰 포함)
  static Future<http.Response> delete(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [DELETE] $url');
    print('📤 Headers: $allHeaders');
    print('📤 Body: $body');
    return await http.delete(Uri.parse(url), headers: allHeaders, body: body);
  }
}