// //채팅 관련 로직 3
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class SocketService {
//   late IO.Socket socket;
//   bool isConnected = false;
//
//   /// 서버와 연결
//   void connect(String serverUrl) {
//     try {
//       socket = IO.io(serverUrl, <String, dynamic>{
//         "transports": ["websocket"], // WebSocket 사용
//         "autoConnect": true,         // 자동 연결
//         "reconnection": true,        // 자동 재연결 활성화
//         "reconnectionAttempts": 5,   // 재연결 시도 횟수
//         "reconnectionDelay": 1000,   // 재연결 대기 시간 (1초)
//       });
//
//       // 연결 이벤트
//       socket.on("connect", (_) {
//         isConnected = true;
//         print("서버에 성공적으로 연결되었습니다!");
//       });
//
//       // 메시지 수신 이벤트
//       socket.on("message", (data) {
//         print("서버에서 받은 메시지: $data");
//       });
//
//       // 연결 해제 이벤트
//       socket.on("disconnect", (_) {
//         isConnected = false;
//         print("서버 연결이 해제되었습니다.");
//       });
//
//       // 에러 이벤트
//       socket.on("connect_error", (error) {
//         isConnected = false;
//         print("서버 연결 에러 발생: $error");
//       });
//
//       // 재연결 시도 이벤트
//       socket.on("reconnect_attempt", (attempt) {
//         print("재연결 시도 중... ($attempt)");
//       });
//
//     } catch (e) {
//       print("소켓 연결 중 오류 발생: $e");
//     }
//   }
//
//   /// 메시지 전송
//   void sendMessage(String message, String roomId) {
//     if (isConnected) {
//       socket.emit("sendMessage", {"roomId": roomId, "message": message});
//       print("보낸 메시지: $message");
//     } else {
//       print("서버와 연결되지 않았습니다. 메시지를 보낼 수 없습니다.");
//     }
//   }
//
//   /// 특정 이벤트 수신 핸들러 추가
//   void onEvent(String eventName, Function(dynamic) callback) {
//     socket.on(eventName, callback);
//   }
//
//   /// 특정 이벤트 핸들러 제거
//   void offEvent(String eventName) {
//     socket.off(eventName);
//   }
//
//   /// 연결 종료
//   void disconnect() {
//     if (isConnected) {
//       socket.disconnect();
//       print("서버와의 연결을 종료합니다.");
//     } else {
//       print("서버에 연결되어 있지 않습니다.");
//     }
//   }
// }