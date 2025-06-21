// import 'package:flutter/material.dart';
//
// class CommunityScreen extends StatefulWidget {
//   @override
//   _CommunityScreenState createState() => _CommunityScreenState();
// }
//
// class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   final List<String> _tabTitles = ['전체', '자유게시판', '인기글', '미션구인', '미션투표'];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabTitles.length, vsync: this);
//     _tabController.addListener(() {
//       setState(() {}); // 탭 변경 시 FAB 조건 반영
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _onAddButtonPressed() {
//     final label = _tabTitles[_tabController.index];
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$label 글 작성 화면으로 이동')),
//     );
//   }
//
//   Widget _buildDummyTab(String label) {
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: 8,
//       separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
//       itemBuilder: (context, index) => ListTile(
//         leading: const Icon(Icons.article),
//         title: Text('$label 글 제목 $index'),
//         subtitle: Text('$label 내용의 첫 줄 미리보기입니다.'),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('$label 글 $index 선택됨')),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         elevation: 1,
//         centerTitle: true,
//         title: const Text(
//           '커뮤니티',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.black),
//             onPressed: () {
//               // 검색 기능 예정
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('검색 기능 준비 중')),
//               );
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(40),
//           child: Container(
//             alignment: Alignment.centerLeft,
//             child: TabBar(
//               controller: _tabController,
//               isScrollable: true,
//               labelColor: Colors.lightBlue,
//               unselectedLabelColor: Colors.black54,
//               indicatorColor: Colors.lightBlue,
//               indicatorWeight: 2,
//               labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
//             ),
//           ),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _tabTitles.map((title) => _buildDummyTab(title)).toList(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _onAddButtonPressed,
//         backgroundColor: Colors.lightBlueAccent,
//         child: const Icon(Icons.edit),
//       ),
//     );
//   }
// }