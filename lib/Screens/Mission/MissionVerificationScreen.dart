import 'package:flutter/material.dart';
import '../../Camera&Photo/CameraMain.dart';

class MissionVerificationScreen extends StatefulWidget {
  final String rId;
  final String u2Id;

  MissionVerificationScreen({required this.rId, required this.u2Id});

  @override
  _MissionVerificationScreenState createState() =>
      _MissionVerificationScreenState();
}

class _MissionVerificationScreenState extends State<MissionVerificationScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToCameraScreen(); // 카메라 화면으로 자동 이동
  }

  Future<void> _navigateToCameraScreen() async {
    await Future.delayed(Duration(milliseconds: 500)); // 짧은 대기 시간 추가
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(rId: widget.rId, u2Id: widget.u2Id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 인증'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // 로딩 표시
            SizedBox(height: 16),
            Text("카메라를 로딩 중입니다..."),
          ],
        ),
      ),
    );
  }
}