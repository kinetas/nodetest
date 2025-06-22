// UserInfo_all.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../SessionTokenManager.dart';

class UserInfoAll {
  final String apiUrl = "http://13.125.65.151:3000/auth/api/user-info/user-all";

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    try {
      String? token = await SessionTokenManager.getToken();
      if (token == null) throw Exception("Session token not found.");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      print('📦 [UserInfoAll] 응답 상태: ${response.statusCode}');
      print('📦 [UserInfoAll] 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception("Failed to fetch user info. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching user info: $e");
      return null;
    }
  }
}
