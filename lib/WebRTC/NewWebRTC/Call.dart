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

  Future<void> _stopCall() async {
    if (_disposed) return;
    _disposed = true;

    print('📴 통화 종료');
    _callTimer?.cancel();

    await _peerConnection?.close();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();

    _channel.sink.add(json.encode({'type': 'leave', 'from': widget.myId, 'to': widget.friendId}));
    _channel.sink.close();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    print('📷 렌더러 초기화 완료');
  }

  Future<String> _getJwtToken() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) throw Exception('JWT 토큰 없음');
    return token;
  }

  void _connectSignaling() async {
    final token = await _getJwtToken();

    print('🌐 WebSocket 연결 중...');
    _channel = WebSocketChannel.connect(Uri.parse('ws://27.113.11.48:3005'));
    _channel.sink.add(json.encode({'type': 'auth', 'token': token}));

    _channel.stream.listen((data) async {
      final msg = json.decode(data);
      print('📩 수신 메시지: $msg');
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
          print('📞 상대방이 수락했습니다.');
          await _createAndSendOffer();
          _startCallTimer();
          break;
        case 'call_rejected':
          print('📵 상대방이 전화를 거절했습니다.');
          Navigator.pop(context);
          break;
      }
    }, onDone: () {
      print('🛑 signaling closed');
    }, onError: (e) {
      print('❌ signaling error: $e');
    });

    await _setupWebRTC();

    if (!widget.isCaller) {
      _sendMessage('accept_call', {'from': widget.myId, 'to': widget.friendId});
      _startCallTimer();
    }
  }

  Future<void> _setupWebRTC() async {
    final config = {'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]};

    _peerConnection = await createPeerConnection(config);

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': {'facingMode': 'user'}});
    _localRenderer.srcObject = _localStream;

    _localStream!.getTracks().forEach((track) => _peerConnection!.addTrack(track, _localStream!));

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) setState(() => _remoteRenderer.srcObject = event.streams[0]);
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendMessage('candidate', {
          'candidate': candidate.toMap(),
        });
      }
    };

    if (widget.isCaller) await _createAndSendOffer();
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
    await _peerConnection!.addCandidate(RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']));
  }

  void _sendMessage(String type, Map<String, dynamic> data) {
    _channel.sink.add(json.encode({'type': type, 'from': widget.myId, 'to': widget.friendId, ...data}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(child: RTCVideoView(_remoteRenderer)),
        Positioned(top: 40, right: 20, child: SizedBox(width: 120, height: 160, child: RTCVideoView(_localRenderer, mirror: true))),
        Positioned(top: 40, left: 20, child: Text('⏱️ ${_formatDuration(_callDuration)}', style: const TextStyle(color: Colors.white))),
        Align(alignment: Alignment.bottomCenter, child: FloatingActionButton(backgroundColor: Colors.red, child: const Icon(Icons.call_end), onPressed: () => Navigator.pop(context))),
      ]),
    );
  }
}
