import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class Signaling {
  final String url;
  final void Function(String from, String type, dynamic payload) onMessage;
  late WebSocketChannel _channel;

  String myId = ''; // ✅ 내 ID 저장용 필드

  Signaling({required this.url, required this.onMessage});

  /// 내 ID 설정 함수
  void setMyId(String id) {
    myId = id;
  }

  /// 서버와 WebSocket 연결
  void connect() {
    print('🔌 Connecting to signaling server: $url');
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((message) {
      print('📥 Received message: $message');
      try {
        final data = jsonDecode(message);
        final from = data['from'] ?? '';
        final type = data['type'];
        final payload = data['payload'];

        if (type != null) {
          onMessage(from, type, payload);
        } else {
          print('⚠️ Invalid message type: $data');
        }
      } catch (e) {
        print('❗ Error parsing message: $e');
      }
    }, onError: (error) {
      print('❗ WebSocket error: $error');
    }, onDone: () {
      print('❗ WebSocket connection closed');
    });
  }

  /// 메시지 전송 (✅ from 필드 포함!)
  void send(String targetId, String type, dynamic payload) {
    final message = {
      'from': myId,     // ✅ 여기 추가됨 (필수)
      'targetId': targetId,
      'type': type,
      'payload': payload,
    };
    final jsonString = jsonEncode(message);

    print('📤 Sending message: $jsonString');
    _channel.sink.add(jsonString);
  }

  /// 연결 종료
  void close() {
    print('🔌 Closing signaling connection');
    _channel.sink.close();
  }
}