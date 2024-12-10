import 'package:flutter/material.dart';
import '../Mission/MissionScreen.dart'; // MissionScreen import
import '../../Screens/Mission/YouAndIMissionList.dart';

class ChatPlusButton extends StatelessWidget {
  final Map<String, dynamic> roomData; // roomData 전달받기

  const ChatPlusButton({
    required this.roomData,
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
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircleButton(
              context,
              Icons.add,
              '미션 만들기',
                  () => _navigateToScreen(context, MissionScreen()),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.lightBlue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.bold,
            ),
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