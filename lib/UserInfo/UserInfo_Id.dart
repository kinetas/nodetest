
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../SessionTokenManager.dart'; // ✅ 세션 토큰 기반 요청 처리

class UserInfoId {
  final String apiUrl = "http://13.125.65.151:3000/auth/api/user-info/user-id";


  // u_id 값을 가져오는 메서드
  Future<String?> fetchUserId() async {
    try {
      // ✅ 세션 토큰 가져오기
      String? token = await SessionTokenManager.getToken();
      if (token == null) {
        throw Exception("Session token not found.");
      }

      // ✅ 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      print('📦 [UserInfoId] 응답 상태: ${response.statusCode}');
      print('📦 [UserInfoId] 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null && responseData['userId'] != null) {
          return responseData['userId'] ?? responseData['u_id'];
        } else {
          throw Exception("userId not found in the response.");
        }
      } else {
        throw Exception("Failed to fetch user ID. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching user ID: $e");
      return null;
    }
  }
}