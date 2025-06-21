// /*
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import '../../SessionTokenManager.dart'; // ✅ 변경된 토큰 매니저 사용
// import 'CommunityPostContent.dart';
//
// class CommunityPostList extends StatefulWidget {
//   @override
//   _CommunityPostListState createState() => _CommunityPostListState();
// }
//
// class _CommunityPostListState extends State<CommunityPostList> {
//   List<dynamic> missions = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMissions();
//   }
//
//   Future<void> fetchMissions() async {
//     try {
//       final url = 'http://27.113.11.48:3000/api/comumunity_missions/list';
//
//       final response = await SessionTokenManager.get(url); // ✅ 여기 변경
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           missions = data['missions'];
//           isLoading = false;
//         });
//       } else {
//         print('Failed to load missions: ${response.statusCode}');
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print('Error occurred while fetching missions: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   String _getStatusLabel(String status) {
//     if (status == 'acc') return '매칭 완료';
//     if (status == 'match') return '매칭 진행 중';
//     return '상태 알 수 없음';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]))
//           : Container(
//         color: Colors.lightBlue[50],
//         child: ListView.builder(
//           itemCount: missions.length,
//           itemBuilder: (context, index) {
//             final mission = missions[index];
//             final isMatchingCompleted = mission['cr_status'] == 'acc';
//
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//               elevation: 3,
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(16.0),
//                 title: Text(
//                   mission['cr_title'] ?? '제목 없음',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: isMatchingCompleted ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 subtitle: Text(
//                   _getStatusLabel(mission['cr_status']),
//                   style: TextStyle(
//                     color: isMatchingCompleted ? Colors.grey : Colors.lightBlue[700],
//                   ),
//                 ),
//                 trailing: Icon(
//                   Icons.arrow_forward_ios,
//                   color: isMatchingCompleted ? Colors.grey : Colors.lightBlue[400],
//                 ),
//                 onTap: isMatchingCompleted
//                     ? null
//                     : () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CommunityPostContent(
//                         crNum: mission['cr_num'],
//                         crTitle: mission['cr_title'],
//                         crStatus: mission['cr_status'],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
// */
//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import '../../SessionTokenManager.dart';
// import 'CommunityPostContent.dart';
//
// class CommunityPostList extends StatefulWidget {
//   @override
//   _CommunityPostListState createState() => _CommunityPostListState();
// }
//
// class _CommunityPostListState extends State<CommunityPostList> {
//   List<dynamic> missions = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMissions();
//   }
//
//   Future<void> fetchMissions() async {
//     try {
//       final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list';
//       final response = await SessionTokenManager.get(url);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         // ✅ 응답 구조 확인 및 안전 파싱
//         final raw = data['missions'];
//         if (raw is List) {
//           setState(() {
//             missions = raw;
//             isLoading = false;
//           });
//         } else {
//           print('❗ missions가 리스트 타입이 아닙니다: $raw');
//           setState(() {
//             missions = [];
//             isLoading = false;
//           });
//         }
//       } else {
//         print('❌ 미션 요청 실패: ${response.statusCode}');
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print('❗ 예외 발생: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   String _getStatusLabel(String status) {
//     if (status == 'acc') return '매칭 완료';
//     if (status == 'match') return '매칭 진행 중';
//     return '상태 알 수 없음';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]));
//     }
//
//     if (missions.isEmpty) {
//       return Center(
//         child: Text(
//           '등록된 게시글이 없습니다.',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: missions.length,
//       itemBuilder: (context, index) {
//         final mission = missions[index];
//         final isMatchingCompleted = mission['cr_status'] == 'acc';
//
//         return Card(
//           color: isMatchingCompleted ? Colors.grey.shade200 : Colors.white,
//           margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//           elevation: 3,
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(16.0),
//             title: Text(
//               mission['cr_title'] ?? '제목 없음',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             subtitle: Text(
//               _getStatusLabel(mission['cr_status']),
//               style: TextStyle(
//                 color: isMatchingCompleted ? Colors.grey : Colors.lightBlue[700],
//               ),
//             ),
//             trailing: Icon(
//               Icons.arrow_forward_ios,
//               color: isMatchingCompleted ? Colors.grey : Colors.lightBlue[400],
//               size: 16,
//             ),
//             onTap: isMatchingCompleted
//                 ? null
//                 : () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CommunityPostContent(
//                     crNum: mission['cr_num'],
//                     crTitle: mission['cr_title'],
//                     crStatus: mission['cr_status'],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }