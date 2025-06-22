import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class SessionTokenManager {
  static const _tokenKey = 'access_token';
  static String? _token;

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    return _token = prefs.getString(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && !JwtDecoder.isExpired(token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<http.Response> get(String url) async {
    final token = await getToken();
    print('📤 [GET] $url with Bearer $token');
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [POST] $url\nHeaders: $allHeaders\nBody: $body');
    return await http.post(Uri.parse(url), headers: allHeaders, body: body);
  }

  static Future<http.Response> put(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [PUT] $url\nHeaders: $allHeaders\nBody: $body');
    return await http.put(Uri.parse(url), headers: allHeaders, body: body);
  }

  static Future<http.Response> delete(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [DELETE] $url\nHeaders: $allHeaders\nBody: $body');
    return await http.delete(Uri.parse(url), headers: allHeaders, body: body);
  }
}