// import 'package:flutter/material.dart';
// import '../../WebRTC/WebRTCService/CallInitiateScreen.dart';
// import '../../WebRTC/WebRTCtest/signaling.dart';
// import '../../UserInfo/UserInfo_Id.dart'; // ✅ 사용자 ID 가져오기 클래스 import
//
// class SendSignaling extends StatefulWidget {
//   final String friendId;
//
//   const SendSignaling({required this.friendId, super.key});
//
//   @override
//   State<SendSignaling> createState() => _SendSignalingState();
// }
//
// class _SendSignalingState extends State<SendSignaling> {
//   late Signaling signaling;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeSignaling(); // 🔁 async 초기화 함수 호출
//   }
//
//   Future<void> _initializeSignaling() async {
//     signaling = Signaling(url: 'ws://:3005/ws');
//
//     // ✅ 사용자 ID 가져오기
//     String? myId = await UserInfoId().fetchUserId();
//
//     if (myId == null) {
//       print("❌ 사용자 ID를 가져올 수 없습니다. 연결 중단.");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('사용자 정보 로딩 실패')),
//         );
//       }
//       return;
//     }
//
//     signaling.setMyId(myId); // ✅ 실제 사용자 ID 설정
//
//     signaling.setOnMessage((from, type, payload) {
//       print('📡 메시지 수신: $type from $from');
//     });
//
//     signaling.connect();
//
//     // 연결 이후 CallInitiateScreen으로 이동
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => CallInitiateScreen(
//             friendId: widget.friendId,
//              // ← signaling 전달 필요 시 이 부분 활성화
//           ),
//         ),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     signaling.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('영상통화 연결 준비 중...', style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }