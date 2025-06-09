import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:math';
import 'signaling.dart';
import 'webRTC_peer.dart';
import '../../UserInfo/UserInfo_Id.dart';

class CallWebRTC extends StatefulWidget {
  final String friendId;
  final bool isIncomingCall;
  final String callerId;
  final Signaling signaling;

  const CallWebRTC({
    required this.friendId,
    this.isIncomingCall = false,
    this.callerId = '',
    required this.signaling,
    super.key,
  });

  @override
  State<CallWebRTC> createState() => _CallWebRTCState();
}

class _CallWebRTCState extends State<CallWebRTC> {
  late WebRTCPeer _peer;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  String myId = '';
  bool _hasIncomingCall = false;
  String incomingOfferFrom = '';

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initConnection();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initConnection() async {
    myId = await UserInfoId().fetchUserId() ?? _generateSimpleId();
    print('🆔 내 ID: $myId / 📞 상대 ID: ${widget.friendId}');

    widget.signaling.setMyId(myId);
    widget.signaling.setOnMessage(_handleMessage);
    widget.signaling.connect();

    _peer = WebRTCPeer(onAddRemoteStream: (stream) {
      _remoteRenderer.srcObject = stream;
    });

    await _peer.init();
    _localRenderer.srcObject = _peer.localStream;

    // join 이벤트 전송
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.signaling.send('broadcast', 'join', {'userId': myId});
    });

    // 발신자라면 바로 offer 전송
    if (!widget.isIncomingCall) {
      Future.delayed(const Duration(milliseconds: 800), () async {
        final offer = await _peer.createOffer();
        widget.signaling.send(widget.friendId, 'offer', {
          ...offer.toMap(),
          'from': myId,
        });
      });
    }
  }

  void _handleMessage(String from, String type, dynamic payload) async {
    print("📩 메시지 수신: $type from $from");

    switch (type) {
      case 'offer':
        incomingOfferFrom = from;
        await _peer.setRemoteDescription(
          RTCSessionDescription(payload['sdp'], payload['type']),
        );
        setState(() => _hasIncomingCall = true);
        break;

      case 'answer':
        await _peer.setRemoteDescription(
          RTCSessionDescription(payload['sdp'], payload['type']),
        );
        break;

      case 'candidate':
        await _peer.addIceCandidate(
          RTCIceCandidate(
            payload['candidate'],
            payload['sdpMid'],
            payload['sdpMLineIndex'],
          ),
        );
        break;
    }
  }

  void _acceptCall() async {
    if (incomingOfferFrom.isEmpty) return;

    final answer = await _peer.createAnswer();
    widget.signaling.send(incomingOfferFrom, 'answer', {
      ...answer.toMap(),
      'from': myId,
    });

    setState(() => _hasIncomingCall = false);
  }

  String _generateSimpleId() {
    const chars = 'abcdef12345';
    final rand = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peer.dispose();
    widget.signaling.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📞 ${widget.friendId}와의 통화")),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          const Divider(),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          if (_hasIncomingCall)
            ElevatedButton(
              onPressed: _acceptCall,
              child: const Text('📞 전화 받기'),
            ),
        ],
      ),
    );
  }
}