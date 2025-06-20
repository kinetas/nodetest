import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';

class MissionVoteDetailScreen extends StatefulWidget {
  final String cNum;

  const MissionVoteDetailScreen({Key? key, required this.cNum}) : super(key: key);

  @override
  State<MissionVoteDetailScreen> createState() => _MissionVoteDetailScreenState();
}

class _MissionVoteDetailScreenState extends State<MissionVoteDetailScreen> {
  Map<String, dynamic>? voteData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVoteDetail();
  }

  Future<void> fetchVoteDetail() async {
    final response = await SessionTokenManager.get('http://27.113.11.48:3000/nodetest/api/cVote');

    if (response.statusCode == 200) {
      final votes = json.decode(response.body)['votes'];
      final match = votes.firstWhere((v) => v['c_number'] == widget.cNum, orElse: () => null);
      if (match != null) {
        setState(() {
          voteData = match;
          isLoading = false;
        });
      }
    } else {
      print('❌ 투표 상세 조회 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || voteData == null) {
      return Scaffold( // 🔧 여기서 const 제거
        appBar: AppBar(title: Text('미션투표')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('미션투표', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, // 옵션 메뉴
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 유저 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voteData?['u_id'] ?? '익명', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${voteData?['c_date']?.toString().split("T")[0]} · 추천 ${voteData?['c_good'] ?? 0} · 반대 ${voteData?['c_bad'] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// 찬반 수
            Row(
              children: [
                Text('찬성 ${voteData?['c_good'] ?? 0}', style: const TextStyle(color: Colors.cyan, fontSize: 13)),
                const SizedBox(width: 12),
                Text('반대 ${voteData?['c_bad'] ?? 0}', style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),

            /// 제목
            Text(
              voteData?['c_title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// 내용
            Text(
              voteData?['c_contents'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            /// 이미지
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 48),
            ),
            const SizedBox(height: 30),

            /// 투표 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: 찬성 처리 로직
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.cyan[50],
                    side: const BorderSide(color: Colors.cyan),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('찬성'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 반대 처리 로직
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.red[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('반대'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}