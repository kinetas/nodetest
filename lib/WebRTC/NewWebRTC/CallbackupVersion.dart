// 📞 Call.dart - signaling 대기 후 수락 시 WebRTC 초기화 구조 반영
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../UserInfo/UserInfo_Id.dart';

// ========== Signaling 클래스 ==========
class Signaling {
  final String url;
  WebSocketChannel? _channel;
  late void Function(String from, String type, dynamic payload) _onMessage;
  String myId = '';

  bool get isConnected => _channel != null;

  Signaling({required this.url, void Function(String from, String type, dynamic payload)? onMessage}) {
    if (onMessage != null) _onMessage = onMessage;
  }

  void setOnMessage(void Function(String from, String type, dynamic payload) handler) => _onMessage = handler;
  void setMyId(String id) => myId = id;

  void connect() {
    if (_channel != null) {
      print('⚠️ signaling 이미 연결됨. 생략.');
      return;
    }

    print('🔌 Connecting to signaling server: $url');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      print('✅ signaling 서버 연결 성공');
    } catch (e) {
      print('❌ signaling 서버 연결 실패: $e');
      return;
    }

    _channel!.stream.listen((message) {
      print('📥 Received message: $message');
      try {
        final data = jsonDecode(message);
        final from = data['from'] ?? '';
        final type = data['type'];
        final payload = data['payload'];
        if (type != null) _onMessage(from, type, payload);
      } catch (e) {
        print('❗ Error parsing message: $e');
      }
    }, onError: (error) {
      print('❗ WebSocket error: $error');
    }, onDone: () {
      print('❌ WebSocket connection closed');
      _channel = null;
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (myId.isNotEmpty) {
        send(myId, 'join', {'userId': myId});
      } else {
        print('⚠️ myId is empty. Cannot join signaling server.');
      }
    });
  }

  void send(String targetId, String type, dynamic payload) {
    if (_channel == null) {
      print('❌ WebSocket is not connected. 메시지 전송 실패');
      return;
    }

    final jsonString = jsonEncode({
      'from': myId,
      'targetId': targetId,
      'type': type,
      'payload': payload
    });
    print('📤 Sending message: $jsonString');
    _channel!.sink.add(jsonString);
  }

  void close() {
    print('🔌 Closing signaling connection');
    _channel?.sink.close();
    _channel = null;
  }
}

// ========== WebRTCPeer 클래스 ==========
class WebRTCPeer {
  final void Function(MediaStream stream) onAddRemoteStream;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  WebRTCPeer({required this.onAddRemoteStream});

  Future<void> init() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'turn::15000', 'username': 'user', 'credential': 'pass'},
      ]
    };
    _peerConnection = await createPeerConnection(config);
    _peerConnection?.onTrack = (event) {
      onAddRemoteStream(event.streams.first);
    };
    _localStream!.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  MediaStream? get localStream => _localStream;

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _peerConnection!.setRemoteDescription(desc);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  RTCPeerConnection? get peerConnection => _peerConnection;

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
  }
}

// ========== CallScreen 위젯 ==========
class CallScreen extends StatefulWidget {
  final String peerId;
  final bool isCaller;
  const CallScreen({required this.peerId, required this.isCaller, super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  WebRTCPeer? rtcPeer;
  late Signaling signaling;
  String? myId;

  @override
  void initState() {
    super.initState();
    initRenderers();
    initSignaling();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> initSignaling() async {
    myId = await UserInfoId().fetchUserId();
    signaling = Signaling(url: 'ws://27.113.11.48:3005/ws');
    signaling.setMyId(myId!);

    signaling.setOnMessage((from, type, payload) async {
      print('📨 signaling 메시지 수신: $type from $from');

      try {
        if (type == 'offer') {
          final accept = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('📞 전화 수신'),
              content: Text('$from 님이 영상통화를 요청했습니다. 수락하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('거절')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('수락')),
              ],
            ),
          );

          if (accept == true) {
            rtcPeer = WebRTCPeer(onAddRemoteStream: (stream) {
              remoteRenderer.srcObject = stream;
            });
            await rtcPeer!.init();
            localRenderer.srcObject = rtcPeer!.localStream;

            rtcPeer!.peerConnection?.onIceCandidate = (candidate) {
              if (candidate != null) {
                signaling.send(from, 'candidate', {
                  'candidate': candidate.candidate,
                  'sdpMid': candidate.sdpMid,
                  'sdpMLineIndex': candidate.sdpMLineIndex
                });
              }
            };

            await rtcPeer!.setRemoteDescription(
              RTCSessionDescription(payload['sdp'], payload['type']),
            );

            final answer = await rtcPeer!.createAnswer();
            signaling.send(from, 'answer', {'sdp': answer.sdp, 'type': answer.type});
          }
        } else if (type == 'answer') {
          await rtcPeer?.setRemoteDescription(
            RTCSessionDescription(payload['sdp'], payload['type']),
          );
        } else if (type == 'candidate') {
          await rtcPeer?.addIceCandidate(
            RTCIceCandidate(payload['candidate'], payload['sdpMid'], payload['sdpMLineIndex']),
          );
        }
      } catch (e) {
        print("❌ signaling 처리 중 오류: $e");
      }
    });

    if (!signaling.isConnected) {
      signaling.connect();
    }

    if (widget.isCaller) {
      rtcPeer = WebRTCPeer(onAddRemoteStream: (stream) {
        remoteRenderer.srcObject = stream;
      });
      await rtcPeer!.init();
      localRenderer.srcObject = rtcPeer!.localStream;

      rtcPeer!.peerConnection?.onIceCandidate = (candidate) {
        if (candidate != null) {
          signaling.send(widget.peerId, 'candidate', {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex
          });
        }
      };

      final offer = await rtcPeer!.createOffer();
      signaling.send(widget.peerId, 'offer', {'sdp': offer.sdp, 'type': offer.type});
    }
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    rtcPeer?.dispose();
    // ❌ signaling.close() 제거 (앱에서 연결 유지)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Positioned.fill(child: RTCVideoView(remoteRenderer)),
        Positioned(
          right: 20,
          top: 40,
          width: 120,
          height: 160,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(8)),
            child: RTCVideoView(localRenderer, mirror: true),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 30,
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        )
      ],
    ),
  );
}