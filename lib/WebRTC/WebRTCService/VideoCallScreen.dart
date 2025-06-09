import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  final bool isCaller;
  final String peerId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const VideoCallScreen({
    required this.isCaller,
    required this.peerId,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  void dispose() {
    widget.localRenderer.dispose();
    widget.remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('영상 통화', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(widget.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
          ),
          Positioned(
            right: 16,
            top: 16,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RTCVideoView(widget.localRenderer, mirror: true),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.volume_up, () {}, Colors.white),
                  _buildActionButton(Icons.call_end, () {
                    Navigator.pop(context);
                  }, Colors.red),
                  _buildActionButton(Icons.mic, () {}, Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 28,
      child: IconButton(
        icon: Icon(icon, color: color == Colors.red ? Colors.white : Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}