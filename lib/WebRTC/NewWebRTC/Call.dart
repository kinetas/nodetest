import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../SessionTokenManager.dart';

class CallScreen extends StatefulWidget {
  final bool isCaller;
  final String myId;
  final String friendId;

  const CallScreen({
    super.key,
    required this.isCaller,
    required this.myId,
    required this.friendId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  late WebSocketChannel _channel;

  Timer? _callTimer;
  int _callDuration = 0;
  bool _disposed = false;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSignaling();
  }

  @override
  void dispose() {
    _stopCall();
    super.dispose();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration++);
    });
  }

  Future<void> _stopCall({bool notify = true}) async {
    if (_disposed) return;
    _disposed = true;

    _callTimer?.cancel();

    await _peerConnection?.close();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _localStream?.dispose();

    if (notify) {
      _channel.sink.add(json.encode({
        'type': 'leave',
        'from': widget.myId,
        'to': widget.friendId,
      }));
    }

    await _channel.sink.close();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<String> _getJwtToken() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) throw Exception('JWT 토큰 없음');
    return token;
  }

  void _connectSignaling() async {
    final token = await _getJwtToken();

    _channel = WebSocketChannel.connect(Uri.parse('ws://27.113.11.48:3005'));
    _channel.sink.add(json.encode({'type': 'auth', 'token': token}));

    _channel.stream.listen((data) async {
      final msg = json.decode(data);
      switch (msg['type']) {
        case 'offer':
          await _handleOffer(msg['sdp']);
          break;
        case 'answer':
          await _handleAnswer(msg['sdp']);
          break;
        case 'candidate':
          await _handleCandidate(msg['candidate']);
          break;
        case 'accept_call':
          await _createAndSendOffer();
          _startCallTimer();
          break;
        case 'call_rejected':
        case 'leave':
          if (mounted) {
            await _stopCall(notify: false);
            if (Navigator.canPop(context)) Navigator.pop(context);
            _showDialog('통화 종료',
                msg['type'] == 'call_rejected' ? '상대방이 거절했습니다.' : '상대방이 종료했습니다.');
          }
          break;
      }
    });

    await _setupWebRTC();

    if (!widget.isCaller) {
      _sendMessage('accept_call', {});
      _startCallTimer();
    }
  }

  Future<void> _setupWebRTC() async {
    final config = {'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]};
    _peerConnection = await createPeerConnection(config);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() => _remoteRenderer.srcObject = event.streams[0]);
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendMessage('candidate', {'candidate': candidate.toMap()});
      }
    };

    if (widget.isCaller) {
      await _createAndSendOffer();
    }
  }

  Future<void> _createAndSendOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _sendMessage('offer', {'sdp': offer.sdp});
  }

  Future<void> _handleOffer(String sdp) async {
    final desc = RTCSessionDescription(sdp, 'offer');
    await _peerConnection!.setRemoteDescription(desc);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    _sendMessage('answer', {'sdp': answer.sdp});
  }

  Future<void> _handleAnswer(String sdp) async {
    final desc = RTCSessionDescription(sdp, 'answer');
    await _peerConnection!.setRemoteDescription(desc);
  }

  Future<void> _handleCandidate(Map<String, dynamic> candidate) async {
    await _peerConnection!.addCandidate(
      RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']),
    );
  }

  void _sendMessage(String type, Map<String, dynamic> data) {
    _channel.sink.add(json.encode({
      'type': type,
      'from': widget.myId,
      'to': widget.friendId,
      ...data,
    }));
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: RTCVideoView(_remoteRenderer)),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              '⏱️ ${_formatDuration(_callDuration)}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 20,
            top: 40,
            child: Container(
              width: size.width * 0.3,
              height: size.height * 0.2,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.call_end, color: Colors.white),
                label: Text('통화 종료', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  await _stopCall();
                  if (mounted) {
                    Navigator.pop(context);
                    _showDialog('통화 종료', '통화를 종료했습니다.');
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}