import 'package:flutter/material.dart';
import '../../../Camera&Photo/CameraMain.dart';

class MissionVerificationScreen extends StatefulWidget {
  final String rId;
  final String u1Id;
  final String u2Id;
  final String mId;
  final String missionAuthenticationAuthority;
  final String? voteM; // 선택적 파라미터

  MissionVerificationScreen({
    required this.rId,
    required this.u1Id,
    required this.u2Id,
    required this.mId,
    required this.missionAuthenticationAuthority,
    this.voteM,
  });

  @override
  _MissionVerificationScreenState createState() =>
      _MissionVerificationScreenState();
}

class _MissionVerificationScreenState extends State<MissionVerificationScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToCameraScreen(); // 자동 이동
  }

  Future<void> _navigateToCameraScreen() async {
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 대기

    // 📤 디버깅 출력
    print('📸 [MissionVerificationScreen → CameraScreen]');
    print('rId: ${widget.rId}');
    print('u1Id: ${widget.u1Id}');
    print('u2Id: ${widget.u2Id}');
    print('mId: ${widget.mId}');
    print('missionAuthenticationAuthority: ${widget.missionAuthenticationAuthority}');
    print('voteM: ${widget.voteM}');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            rId: widget.rId,
            u1Id: widget.u1Id,
            u2Id: widget.u2Id,
            mId: widget.mId,
            missionAuthenticationAuthority: widget.missionAuthenticationAuthority,
            voteM: widget.voteM,
          ),
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
            Navigator.pop(context); // 뒤로 가기
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("카메라를 로딩 중입니다..."),
          ],
        ),
      ),
    );
  }
}