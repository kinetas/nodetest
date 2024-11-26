// //채팅방 관련 로직 --2
// import 'package:flutter/material.dart';
// import 'ChatService.dart';
// import 'SocketService.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService();
//   final SocketService _socketService = SocketService();
//   final TextEditingController _messageController = TextEditingController();
//   List<String> _messages = [];
//   String _roomId = "room123";
//   bool _isConnected = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeSocket();
//     _fetchMessages();
//   }
//
//   @override
//   void dispose() {
//     _socketService.disconnect();
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   /// 소켓 초기화 및 연결
//   void _initializeSocket() {
//     _socketService.connect("http://13.124.126.234:3001");
//
//     // 서버 연결 이벤트
//     _socketService.onEvent("connect", (_) {
//       setState(() {
//         _isConnected = true;
//       });
//       print("서버와 연결되었습니다.");
//     });
//
//     // 메시지 수신 이벤트
//     _socketService.onEvent("message", (data) {
//       setState(() {
//         _messages.add(data);
//       });
//       print("새 메시지 수신: $data");
//     });
//
//     // 서버 연결 해제 이벤트
//     _socketService.onEvent("disconnect", (_) {
//       setState(() {
//         _isConnected = false;
//       });
//       print("서버 연결이 종료되었습니다.");
//     });
//
//     // 에러 이벤트
//     _socketService.onEvent("connect_error", (error) {
//       print("소켓 연결 오류: $error");
//     });
//   }
//
//   /// REST API로 메시지 목록 가져오기
//   void _fetchMessages() async {
//     try {
//       List<String> messages = await _chatService.getMessages(_roomId);
//       setState(() {
//         _messages = messages;
//       });
//     } catch (e) {
//       print("메시지 로드 실패: $e");
//     }
//   }
//
//   /// 메시지 보내기
//   void _sendMessage() {
//     String message = _messageController.text.trim();
//     if (message.isEmpty) {
//       print("빈 메시지는 보낼 수 없습니다.");
//       return;
//     }
//
//     if (!_isConnected) {
//       print("서버와 연결되어 있지 않습니다.");
//       return;
//     }
//
//     // REST API로 메시지 저장
//     _chatService.sendMessage(message, _roomId);
//
//     // WebSocket으로 메시지 전송
//     _socketService.sendMessage(message, _roomId);
//
//     // 로컬 메시지 리스트 업데이트
//     setState(() {
//       _messages.add(message);
//     });
//
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat Room"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_messages[index]),
//                 );
//               },
//             ),
//           ),
//           if (!_isConnected)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "서버와 연결되지 않았습니다. 연결 상태를 확인해주세요.",
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _sendMessage,
//                   child: Text("Send"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }