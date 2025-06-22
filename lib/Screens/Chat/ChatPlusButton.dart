
import 'package:flutter/material.dart';
import '../Mission/NewMissionScreen/MyMissionList.dart'; // MyMissionList import
import '../Mission/NewMissionScreen/RequestedMissionList.dart'; // RequestedMissionList import
import '../Mission/NewMissionScreen/GiveMissionList.dart'; // GiveMissionList import
import '../Mission/NewMissionScreen/MyCompleteMissionList.dart'; // MyCompleteMissionList import

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(
                  context,
                  Icons.assignment,
                  '내 미션',
                      () => _navigateToScreen(context, MyMissionList()),
                ),
                _buildCircleButton(
                  context,
                  Icons.pending_actions,
                  '인증 요청 미션',
                      () => _navigateToScreen(context, RequestedMissionScreen()),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(
                  context,
                  Icons.assignment_ind,
                  '부여한 미션',
                      () => _navigateToScreen(context, GiveMissionList()),
                ),
                _buildCircleButton(
                  context,
                  Icons.check,
                  '내가 완료한 미션',
                      () => _navigateToScreen(context, MyCompleteMissionList()),
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