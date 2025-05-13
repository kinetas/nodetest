// WebRTCtest.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

class WebRTCtest2 extends StatefulWidget {
  const WebRTCtest2({super.key});

  @override
  State<WebRTCtest2> createState() => _WebRTCTestState();
}

class _WebRTCTestState extends State<WebRTCtest2> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IOWebSocketChannel? _channel;
  List<RTCIceCandidate> _candidateQueue = [];

  final TextEditingController _selfIdController = TextEditingController(text: 'user_${Random().nextInt(10000)}');
  final TextEditingController _targetIdController = TextEditingController();

  final String wsUrl = 'wss://cuprtc-test.kro.kr:8500/ws';
  bool _connected = false;
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _startLocalStream();
  }

  Future<void> _startLocalStream() async {
    final mediaConstraints = {'audio': true, 'video': {'facingMode': 'user'}};
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    print('[🎞] 로컬 스트림 시작됨 - 트랙 수: ${_localStream?.getTracks().length}');
  }

  Future<void> _connectWebSocket() async {
    final selfId = _selfIdController.text.trim();
    try {
      final socket = await WebSocket.connect(wsUrl, customClient: HttpClient()
        ..badCertificateCallback = (cert, host, port) => true);

      _channel = IOWebSocketChannel(socket);
      _connected = true;
      print('[🌐] WebSocket 연결됨');

      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        final type = data['type'];
        final payload = data['payload'];

        print('[📨] 수신된 메시지 유형: $type');

        switch (type) {
          case 'offer':
            _onOfferReceived(data['from'], payload);
            break;
          case 'answer':
            _onAnswerReceived(payload);
            break;
          case 'candidate':
            _onCandidateReceived(payload);
            break;
          case 'userlist':
            setState(() {
              _users = List<String>.from(data['users']).toSet().toList();
              _users.remove(selfId);
              print('[👥] 사용자 목록 업데이트: $_users');
              if (_users.isNotEmpty) {
                _targetIdController.text = _users.first;
              }
            });
            break;
        }
      });

      _channel!.sink.add(jsonEncode({"type": "join", "userId": selfId, "token": "test-token"}));
      print('[🚪] JOIN 메시지 전송됨: $selfId');
    } catch (e) {
      debugPrint('[WS] 연결 실패: $e');
    }
  }

  Future<void> _createPeerConnection(String selfId, String targetId) async {
    print('[🔧] PeerConnection 생성 중 - selfId: $selfId, targetId: $targetId');
    final config = {
      'iceServers': [
        {
          'urls': ['turn:27.113.11.48:3478?transport=udp'],
          'username': 'gogi',
          'credential': 'gogi0529'
        },
      ]
    };

    _peerConnection = await createPeerConnection(config);
    print('[✅] PeerConnection 생성됨');

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null && _channel != null) {
        _channel!.sink.add(jsonEncode({
          "type": "candidate",
          "from": selfId,
          "target_id": targetId,
          "payload": {
            "candidate": candidate.candidate,
            "sdpMid": candidate.sdpMid,
            "sdpMLineIndex": candidate.sdpMLineIndex
          }
        }));
        print('[❄️] ICE Candidate 발견됨: ${candidate.candidate}');
      }
    };

    _peerConnection!.onTrack = (event) {
      print('[🎮 onTrack] 트랙 수신됨 - kind: ${event.track.kind}, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        print('[✅] 원격 스트림 연결됨');
      } else {
        print('[⚠️] 수신한 트랙에 연결된 stream 없음');
      }
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
      print('[🎧] 로컬 트랙 추가됨: ${track.kind}');
    });
  }

  Future<void> _makeOffer() async {
    final selfId = _selfIdController.text.trim();
    final targetId = _targetIdController.text.trim();
    print('[📞] Offer 시작 - From: $selfId To: $targetId');
    await _createPeerConnection(selfId, targetId);

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    print('[📤] Offer SDP 전송 준비 완료');

    _channel!.sink.add(jsonEncode({
      "type": "offer",
      "from": selfId,
      "target_id": targetId,
      "payload": offer.toMap()
    }));
    print('[📤] Offer 전송 완료');
  }

  Future<void> _onOfferReceived(String from, dynamic payload) async {
    final selfId = _selfIdController.text.trim();
    print('[📥] Offer 수신됨 - From: $from');
    await _createPeerConnection(selfId, from);

    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(payload['sdp'], payload['type']));

    for (var c in _candidateQueue) {
      await _peerConnection!.addCandidate(c);
    }
    _candidateQueue.clear();

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _channel!.sink.add(jsonEncode({
      "type": "answer",
      "from": selfId,
      "target_id": from,
      "payload": answer.toMap()
    }));
    print('[📤] Answer 전송됨');
  }

  Future<void> _onAnswerReceived(dynamic payload) async {
    print('[📥] Answer 수신됨');
    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(payload['sdp'], payload['type']));
  }

  Future<void> _onCandidateReceived(dynamic payload) async {
    final candidate = RTCIceCandidate(
        payload['candidate'], payload['sdpMid'], payload['sdpMLineIndex']);
    print('[📥] Candidate 수신됨: ${candidate.candidate}');
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔪 WebRTC 테스트')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _selfIdController,
                  decoration: const InputDecoration(labelText: '내 ID'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _users.contains(_targetIdController.text)
                      ? _targetIdController.text
                      : null,
                  items: _users.map((id) => DropdownMenuItem(
                    value: id,
                    child: Text(id, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _targetIdController.text = val;
                      print('[📌] 드롭다운 변경됨: $val');
                    }
                  },
                  decoration: const InputDecoration(labelText: '상대 ID'),
                ),
              )
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _connectWebSocket,
                child: const Text("🌐 WebSocket 연결"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _makeOffer,
                child: const Text("📢 통화 요청"),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                Expanded(child: RTCVideoView(_remoteRenderer))
              ],
            ),
          )
        ],
      ),
    );
  }
}