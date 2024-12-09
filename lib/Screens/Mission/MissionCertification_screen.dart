import 'package:flutter/material.dart';
import '../../SessionCookieManager.dart'; // 세션 쿠키 관리 파일

class MissionCertificationScreen extends StatefulWidget {
  final String mId; // m_id 값을 받기 위한 변수

  MissionCertificationScreen({required this.mId}); // 생성자

  @override
  _MissionCertificationScreenState createState() =>
      _MissionCertificationScreenState();
}

class _MissionCertificationScreenState
    extends State<MissionCertificationScreen> {
  bool _isRequestSuccessful = false; // 요청 성공 여부
  bool _isLoading = true; // 로딩 상태

  Future<void> sendMissionRequest() async {
    final String url = "http://54.180.54.31:3000/api/missions/missionRequest";

    try {
      // POST 요청
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'}, // 헤더 설정
        body: '{"m_id": "${widget.mId}"}', // JSON 형식으로 데이터 전송
      );

      if (response.statusCode == 200) {
        setState(() {
          _isRequestSuccessful = true; // 요청 성공 여부 설정
        });
      } else {
        print("Error: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });
    }
  }

  @override
  void initState() {
    super.initState();
    sendMissionRequest(); // 화면 초기화 시 요청 수행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // 반투명 배경
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // 로딩 중 표시
            : _isRequestSuccessful
            ? AlertDialog(
          title: Text("알림"),
          content: Text("미션이 성공적으로 요청되었습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text("닫기"),
            ),
          ],
        )
            : AlertDialog(
          title: Text("오류"),
          content: Text("미션 요청에 실패했습니다. 다시 시도해주세요."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text("닫기"),
            ),
          ],
        ),
      ),
    );
  }
}