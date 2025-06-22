import 'dart:convert';
import 'package:http/http.dart' as http;
import '../SessionTokenManager.dart';

// 미션 카운트 데이터 클래스
class MissionCounts {
  final int successCount;
  final int failCount;
  final int createMissionCount;
  final int assignedMissionCount;

  MissionCounts({
    required this.successCount,
    required this.failCount,
    required this.createMissionCount,
    required this.assignedMissionCount,
  });

  @override
  String toString() {
    return '성공: $successCount, 실패: $failCount, 생성: $createMissionCount, 진행: $assignedMissionCount';
  }
}

// 4가지 미션 카운트 데이터를 한 번에 받아오는 클래스
class UserInfoMissionCount {
  Future<MissionCounts> fetchMissionCounts() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) throw Exception('No token found');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // 4개 API 비동기 호출
    final responses = await Future.wait([
      http.get(Uri.parse('http://13.125.65.151:3000/nodetest/result/success-count'), headers: headers),
      http.get(Uri.parse('http://13.125.65.151:3000/nodetest/result/fail-count'), headers: headers),
      http.get(Uri.parse('http://13.125.65.151:3000/nodetest/dashboard/missions/getCreateMissionNumber'), headers: headers),
      http.get(Uri.parse('http://13.125.65.151:3000/nodetest/dashboard/missions/getAssignedMissionNumber'), headers: headers),
    ]);

    // 각 응답 본문에서 값 추출
    final successCount = (jsonDecode(responses[0].body)['successCount'] ?? 0) as int;
    final failCount = (jsonDecode(responses[1].body)['failCount'] ?? 0) as int;
    final createMissionCount = (jsonDecode(responses[2].body)['createMissionCount'] ?? 0) as int;
    final assignedMissionCount = (jsonDecode(responses[3].body)['assignedMissionCount'] ?? 0) as int;

    return MissionCounts(
      successCount: successCount,
      failCount: failCount,
      createMissionCount: createMissionCount,
      assignedMissionCount: assignedMissionCount,
    );
  }
}
