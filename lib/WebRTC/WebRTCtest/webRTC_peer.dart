import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCPeer {
  final void Function(MediaStream stream) onAddRemoteStream;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  WebRTCPeer({required this.onAddRemoteStream});

  Future<void> init() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      print('✅ Local stream initialized: ${_localStream?.id}');

      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'turn:27.113.11.48:15000', 'username': 'user', 'credential': 'pass'},
          {'urls': 'turn:27.113.11.48:15443?transport=tcp', 'username': 'user', 'credential': 'pass'},
        ],
      };

      _peerConnection = await createPeerConnection(config);
      print('✅ PeerConnection created');

      _peerConnection?.onTrack = (event) {
        print('📡 onTrack: ${event.track.id}');
        if (event.streams.isNotEmpty) {
          print('📡 Remote stream added: ${event.streams[0].id}');
          onAddRemoteStream(event.streams[0]);
        }
      };

      _peerConnection?.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          print('❄️ ICE candidate gathered: ${candidate.candidate}');
        }
      };

      _peerConnection?.onConnectionState = (state) {
        print('🔗 Connection State changed: $state');
      };

      _peerConnection?.onIceConnectionState = (state) {
        print('❄️ ICE Connection State changed: $state');
      };

      for (var track in _localStream!.getTracks()) {
        await _peerConnection?.addTrack(track, _localStream!);
        print('➕ Local track added: ${track.kind}');
      }
    } catch (e) {
      print('❌ Error during WebRTCPeer init: $e');
    }
  }

  MediaStream? get localStream => _localStream;

  Future<RTCSessionDescription> createOffer() async {
    if (_peerConnection == null) {
      throw Exception('PeerConnection is not initialized');
    }

    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      print('📤 Offer created and set as local description');
      return offer;
    } catch (e) {
      print('❌ Error creating offer: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer() async {
    if (_peerConnection == null) {
      throw Exception('PeerConnection is not initialized');
    }

    try {
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      print('📤 Answer created and set as local description');
      return answer;
    } catch (e) {
      print('❌ Error creating answer: $e');
      rethrow;
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    if (_peerConnection == null) {
      throw Exception('PeerConnection is not initialized');
    }

    try {
      await _peerConnection!.setRemoteDescription(desc);
      print('📥 Remote description set: ${desc.type}');
    } catch (e) {
      print('❌ Error setting remote description: $e');
    }
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      print('⚠️ PeerConnection is not initialized');
      return;
    }

    try {
      await _peerConnection!.addCandidate(candidate);
      print('➕ ICE candidate added: ${candidate.candidate}');
    } catch (e) {
      print('❌ Error adding ICE candidate: $e');
    }
  }

  void dispose() {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream?.dispose();
      _peerConnection?.close();
      print('🗑️ WebRTCPeer disposed');
    } catch (e) {
      print('❌ Error during dispose: $e');
    } finally {
      _peerConnection = null;
      _localStream = null;
    }
  }
}