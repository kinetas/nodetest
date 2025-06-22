// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'MissionVoteDetailScreen.dart';
//
// class AllVoteScreen extends StatefulWidget {
//   final String currentCNum; // 현재 투표의 c_number
//
//   const AllVoteScreen({super.key, required this.currentCNum});
//
//   @override
//   State<AllVoteScreen> createState() => _AllVoteScreenState();
// }
//
// class _AllVoteScreenState extends State<AllVoteScreen> {
//   List<Map<String, dynamic>> votes = [];
//   int currentIndex = 0;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchVotes();
//   }
//
//   Future<void> fetchVotes() async {
//     final res = await http.get(Uri.parse("http://13.125.65.151:3000/nodetest/api/cVote"));
//
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       if (data['success'] == true) {
//         final allVotes = List<Map<String, dynamic>>.from(data['votes']);
//         final index = allVotes.indexWhere((v) => v['c_number'] == widget.currentCNum);
//
//         setState(() {
//           votes = allVotes;
//           currentIndex = index >= 0 ? index : 0;
//           isLoading = false;
//         });
//       }
//     } else {
//       print("❌ 투표 데이터 불러오기 실패: ${res.statusCode}");
//     }
//   }
//
//   void goToNext() {
//     if (currentIndex < votes.length - 1) {
//       setState(() {
//         currentIndex++;
//       });
//     }
//   }
//
//   void goToPrevious() {
//     if (currentIndex > 0) {
//       setState(() {
//         currentIndex--;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//
//     return Scaffold(
//       body: PageView.builder(
//         controller: PageController(initialPage: currentIndex),
//         onPageChanged: (index) {
//           setState(() {
//             currentIndex = index;
//           });
//         },
//         itemCount: votes.length,
//         itemBuilder: (context, index) {
//           final vote = votes[index];
//           return MissionVoteDetailScreen(
//             cNum: vote['c_number'], // ✅ 필수 파라미터만 넘겨야 함
//           );
//         },
//       ),
//     );
//   }
// }