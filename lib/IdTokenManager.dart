import 'package:shared_preferences/shared_preferences.dart';

class IdTokenManager {
  static const String _key = 'id_token';

  /// ✅ ID 토큰 저장
  static Future<void> saveIdToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  /// ✅ 저장된 ID 토큰 불러오기
  static Future<String?> getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// ✅ 저장된 ID 토큰 삭제
  static Future<void> clearIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}