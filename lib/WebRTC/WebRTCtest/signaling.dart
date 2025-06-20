// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class Signaling {
//   final String url;
//   late WebSocketChannel _channel;
//
//   late void Function(String from, String type, dynamic payload) _onMessage;
//   String myId = '';
//
//   Signaling({
//     required this.url,
//     void Function(String from, String type, dynamic payload)? onMessage,
//   }) {
//     if (onMessage != null) {
//       _onMessage = onMessage;
//     }
//   }
//
//   void setOnMessage(void Function(String from, String type, dynamic payload) handler) {
//     _onMessage = handler;
//   }
//
//   void setMyId(String id) {
//     myId = id;
//   }
//
//   void connect() {
//     print('🔌 Connecting to signaling server: $url');
//     _channel = WebSocketChannel.connect(Uri.parse(url));
//
//     _channel.stream.listen(
//           (message) {
//         print('📥 Received message: $message');
//         try {
//           final data = jsonDecode(message);
//           final from = data['from'] ?? '';
//           final type = data['type'];
//           final payload = data['payload'];
//
//           if (type != null && _onMessage != null) {
//             _onMessage(from, type, payload);
//           } else {
//             print('⚠️ Invalid message or missing type: $data');
//           }
//         } catch (e) {
//           print('❗ Error parsing message: $e');
//         }
//       },
//       onError: (error) {
//         print('❗ WebSocket error: $error');
//       },
//       onDone: () {
//         print('❗ WebSocket connection closed');
//       },
//     );
//   }
//
//   void send(String targetId, String type, dynamic payload) {
//     final message = {
//       'from': myId,
//       'targetId': targetId,
//       'type': type,
//       'payload': payload,
//     };
//     final jsonString = jsonEncode(message);
//
//     print('📤 Sending message: $jsonString');
//     _channel.sink.add(jsonString);
//   }
//
//   void close() {
//     print('🔌 Closing signaling connection');
//     _channel.sink.close();
//   }
// }