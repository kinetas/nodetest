import 'package:flutter/material.dart';
import '../../../SessionTokenManager.dart'; // ✅ JWT 기반 토큰 매니저 import

class MissionCertificationScreen extends StatefulWidget {
  final String mId;

  const MissionCertificationScreen({required this.mId});

  @override
  _MissionCertificationScreenState createState() =>
      _MissionCertificationScreenState();
}

class _MissionCertificationScreenState
    extends State<MissionCertificationScreen> {

  @override
  void initState() {
    super.initState();
    _sendRequestAndClose();
  }

  Future<void> _sendRequestAndClose() async {
    final String url =
        "http://13.125.65.151:3000/nodetest/api/missions/missionRequest";

    try {
      final response = await SessionTokenManager.post(
        url,
        body: '{"m_id": "${widget.mId}"}',
      );

      if (response.statusCode == 200) {
        print("✅ 미션 인증 요청 성공");
      } else {
        print("❌ 미션 인증 요청 실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // ✅ 자동으로 이전 화면으로 돌아가기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 없이, 투명한 1픽셀 위젯만 반환하여 실제 화면에는 아무것도 안 보이게 처리
    return const SizedBox.shrink();
  }
}