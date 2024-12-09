import 'package:flutter/material.dart';
import '../Mission/MissionVerificationScreen.dart'; // MissionVerificationScreen import
import '../Mission/YouAndIMissionList.dart';

class ChatPlusButton extends StatelessWidget {
  final Map<String, dynamic> roomData; // roomData 전달받기

  const ChatPlusButton({
    required this.roomData, // roomData 추가
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
                      () => _navigateToScreen(context, MissionCreateScreen()),
                ),
                _buildCircleButton(
                  context,
                  Icons.check_circle,
                  '미션 인증',
                      () => _navigateToScreen(
                    context,
                    YouAndIMissionList(
                      rId: roomData['r_id'], // roomData에서 rId 가져오기
                      u2Id: roomData['u2_id'], // roomData에서 u2Id 가져오기

                    ),
                  ),
                ),
                _buildCircleButton(
                  context,
                  Icons.request_page,
                  '미션 요청',
                      () => _navigateToScreen(context, MissionRequestScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onPressed,
      ) {
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

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// 예제 화면 클래스들
class MissionCreateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 생성')),
      body: Center(child: Text('미션 생성 화면')),
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