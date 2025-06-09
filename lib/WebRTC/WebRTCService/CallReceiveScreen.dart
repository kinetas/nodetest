import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../WebRTCtest/signaling.dart';
import 'VideoCallScreen.dart';

class CallReceiveScreen extends StatelessWidget {
  final String callerName;
  final String callerId;
  final Signaling signaling;

  const CallReceiveScreen({
    Key? key,
    required this.callerName,
    required this.callerId,
    required this.signaling,
  }) : super(key: key);

  void _acceptCall(BuildContext context) async {
    signaling.send(callerId, 'accept_call', {});

    final localRenderer = RTCVideoRenderer();
    final remoteRenderer = RTCVideoRenderer();
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          isCaller: false,
          peerId: callerId,
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
        ),
      ),
    );
  }

  void _declineCall(BuildContext context) {
    signaling.send(callerId, 'decline_call', {});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                '$callerName님이 영상통화를 요청했어요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _acceptCall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text('수락'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _declineCall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: Icon(Icons.call_end, color: Colors.white),
                    label: Text('거절'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}