import 'package:flutter/material.dart';

class ChatPlusButton extends StatelessWidget {
  final BuildContext context;

  const ChatPlusButton({
    required this.context,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(
                  context,
                  Icons.add,
                  '미션 생성',
                  _navigateToMissionCreateScreen,
                ),
                _buildCircleButton(
                  context,
                  Icons.check_circle,
                  '미션 인증',
                  _navigateToMissionVerifyScreen,
                ),
                _buildCircleButton(
                  context,
                  Icons.request_page,
                  '미션 요청',
                  _navigateToMissionRequestScreen,
                ),
                _buildCircleButton(
                  context,
                  Icons.card_giftcard,
                  '리워드 요청',
                  _navigateToRewardRequestScreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  /// 미션 생성 화면으로 이동
  void _navigateToMissionCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MissionCreateScreen()),
    );
  }

  /// 미션 인증 화면으로 이동
  void _navigateToMissionVerifyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MissionVerifyScreen()),
    );
  }

  /// 미션 요청 화면으로 이동
  void _navigateToMissionRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MissionRequestScreen()),
    );
  }

  /// 리워드 요청 화면으로 이동
  void _navigateToRewardRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RewardRequestScreen()),
    );
  }
}

// 각각의 화면을 위한 간단한 클래스 예제
class MissionCreateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 생성')),
      body: Center(child: Text('미션 생성 화면')),
    );
  }
}

class MissionVerifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 인증')),
      body: Center(child: Text('미션 인증 화면')),
    );
  }
}

class MissionRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 요청')),
      body: Center(child: Text('미션 요청 화면')),
    );
  }
}

class RewardRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('리워드 요청')),
      body: Center(child: Text('리워드 요청 화면')),
    );
  }
}