import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '📞 전화 수신 중',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://your-api.com/profile/$callerId.jpg',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                callerId,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ❌ 거절 버튼
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final channel = WebSocketChannel.connect(
                          Uri.parse('ws://27.113.11.48:3005'),
                        );

                        channel.sink.add(json.encode({
                          'type': 'call_rejected',
                          'from': myId,
                          'to': callerId,
                        }));

                        await Future.delayed(const Duration(milliseconds: 300));
                        await channel.sink.close();
                      } catch (e) {
                        print('❌ signaling 전송 실패: $e');
                      }

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.call_end),
                    label: const Text('거절'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  // ✅ 수락 버튼
                  ElevatedButton.icon(
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
                    icon: const Icon(Icons.call),
                    label: const Text('수락'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}