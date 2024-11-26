// //채팅 관련 로직 4
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ChatService {
//   final String baseUrl = "https://your-aliexpress-server.com/api";
//
//   Future<void> sendMessage(String message, String roomId) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/sendMessage"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"roomId": roomId, "message": message}),
//     );
//     if (response.statusCode == 200) {
//       print("Message sent successfully");
//     } else {
//       print("Failed to send message: ${response.body}");
//     }
//   }
//
//   Future<List<String>> getMessages(String roomId) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/getMessages?roomId=$roomId"),
//     );
//     if (response.statusCode == 200) {
//       return List<String>.from(jsonDecode(response.body));
//     } else {
//       throw Exception("Failed to load messages");
//     }
//   }
// }