import 'dart:convert';
import 'package:http/http.dart' as http;
import '../SessionCookieManager.dart';

class UserInfoId {
  final String apiUrl = "http://54.180.54.31:3000/api/user-info/user-id";

  // u_id 값을 가져오는 메서드
  Future<String?> fetchUserId() async {
    try {
      // 세션 쿠키 가져오기
      String? sessionCookie = await SessionCookieManager.getSessionCookie();
      if (sessionCookie == null) {
        throw Exception("Session cookie not found.");
      }

      // HTTP 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie,
      };

      // GET 요청 보내기
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      // 응답 상태 확인
      if (response.statusCode == 200) {
        // JSON 파싱
        final responseData = jsonDecode(response.body);
        if (responseData != null && responseData['u_id'] != null) {
          return responseData['u_id'];
        } else {
          throw Exception("u_id not found in the response.");
        }
      } else {
        throw Exception("Failed to fetch user ID. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // 오류 처리
      print("Error fetching user ID: $e");
      return null;
    }
  }
}