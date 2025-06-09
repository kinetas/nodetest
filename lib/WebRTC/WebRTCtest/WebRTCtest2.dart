import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';
import 'webRTC_peer.dart';
import 'dart:math';

class WebRTCtest extends StatefulWidget {
  const WebRTCtest({super.key});

  @override
  State<WebRTCtest> createState() => _WebRTCtestState();
}

class _WebRTCtestState extends State<WebRTCtest> {
  late Signaling _signaling;
  late WebRTCPeer _peer;
  String myId = '';
  String autoPeerId = '';
  String incomingOfferFrom = '';

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final TextEditingController _peerIdController = TextEditingController();

  bool _isMakingOffer = false;
  bool _isRemoteDescriptionSet = false;
  bool _hasIncomingCall = false;  // 🔴 추가

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initSignaling();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initSignaling() {
    myId = _generateSimpleId();
    print('🟢 My User ID: $myId');

    _signaling = Signaling(
      url: 'ws://27.113.11.48:3005/ws',

      onMessage: _handleSignalingMessage,

    );
    _signaling.setMyId(myId);
    _signaling.connect();

    Future.delayed(const Duration(milliseconds: 500), () {
      _signaling.send('broadcast', 'join', {'userId': myId});
    });

    _peer = WebRTCPeer(onAddRemoteStream: (stream) {
      print('📺 Remote stream received: ${stream.id}');
      _remoteRenderer.srcObject = stream;
    });

    _peer.init().then((_) {
      _localRenderer.srcObject = _peer.localStream;
    });
  }
  void _acceptCall() async {
    if (incomingOfferFrom.isEmpty) return;

    final answer = await _peer.createAnswer();

    _signaling.send(
      incomingOfferFrom,
      'answer',
      {
        ...answer.toMap(),
        'from': myId,
      },
    );

    setState(() {
      _hasIncomingCall = false;
    });
  }

  void _handleSignalingMessage(String from, String type, dynamic payload) async {
    print('📩 Message from $from: $type');

    if (from != myId && autoPeerId != from) {
      setState(() {
        autoPeerId = from;
      });
    }

    switch (type) {
      case 'offer':
        incomingOfferFrom = from;
        print('📥 Incoming offer from: $incomingOfferFrom');

        await _peer.setRemoteDescription(
          RTCSessionDescription(payload['sdp'], payload['type']),
        );
        _isRemoteDescriptionSet = true;

        final answer = await _peer.createAnswer();

        _signaling.send(
          incomingOfferFrom, // 🔑 targetId 명확히
          'answer',
          {
            ...answer.toMap(),
            'from': myId, // 🔑 필수로 내 ID도 보냄
          },
        );
        break;

      case 'answer':
        await _peer.setRemoteDescription(
          RTCSessionDescription(payload['sdp'], payload['type']),
        );
        _isMakingOffer = false;
        break;

      case 'candidate':
        if (_isRemoteDescriptionSet) {
          await _peer.addIceCandidate(RTCIceCandidate(
            payload['candidate'],
            payload['sdpMid'],
            payload['sdpMLineIndex'],
          ));
        }
        break;

      case 'join':
        if (from != myId) {
          setState(() {
            autoPeerId = from;
          });
        }
        break;
    }
  }

  void _startCall() async {
    final targetPeerId = _peerIdController.text.isNotEmpty
        ? _peerIdController.text
        : autoPeerId;

    if (targetPeerId.isEmpty) {
      print('❗ No peer to call');
      return;
    }

    print('📞 Starting call to: $targetPeerId');
    _isMakingOffer = true;

    final offer = await _peer.createOffer();

    _signaling.send(
      targetPeerId, // 🔑 targetId 확실히 지정
      'offer',
      {
        ...offer.toMap(),
        'from': myId, // 🔑 내 ID도 포함
      },
    );
  }

  String _generateSimpleId() {
    const chars = 'abcde12345';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(4, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peer.dispose();
    _signaling.close();
    _peerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebRTC Test')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer)),
          const Divider(),
          Expanded(child: RTCVideoView(_remoteRenderer)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('My ID: $myId'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Auto Peer ID: ${autoPeerId.isEmpty ? "대기중..." : autoPeerId}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _peerIdController,
              decoration: const InputDecoration(labelText: 'Peer ID (manual input)'),
            ),
          ),
          ElevatedButton(
            onPressed: _startCall,
            child: const Text('Start Call'),
          ),
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