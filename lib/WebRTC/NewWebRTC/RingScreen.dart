import 'package:flutter/material.dart';
import 'Call.dart';

class RingScreen extends StatelessWidget {
  final String callerId;
  final String myId;

  const RingScreen({
    super.key,
    required this.callerId,
    required this.myId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📞 전화 수신 중...',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://your-api.com/profile/$callerId.jpg', // 프로필 이미지 경로 예시
              ),
            ),
            const SizedBox(height: 10),
            Text(
              callerId,
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 📴 거절 버튼
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 40),
                  onPressed: () {
                    // 거절 시 pop 처리 또는 서버에 "거절" 전송
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 60),
                // ✅ 수락 버튼
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green, size: 40),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          isCaller: false,
                          myId: myId,
                          friendId: callerId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}