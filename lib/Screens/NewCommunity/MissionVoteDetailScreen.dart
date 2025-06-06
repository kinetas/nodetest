import 'package:flutter/material.dart';

class MissionVoteDetailScreen extends StatelessWidget {
  const MissionVoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    Text('유저 닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('2025/04/14 11:10 · 조회 00 · 추천 00', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// 찬반 수
            Row(
              children: const [
                Text('찬성 00', style: TextStyle(color: Colors.cyan, fontSize: 13)),
                SizedBox(width: 12),
                Text('반대 00', style: TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),

            /// 제목
            const Text(
              '제목이 들어갈 부분\n예) 이런 미션 했습니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// 내용
            const Text(
              '미션에 대한 내용',
              style: TextStyle(fontSize: 16),
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
                /// 찬성
                ElevatedButton(
                  onPressed: () {
                    // TODO: 찬성 로직 처리
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

                /// 반대
                ElevatedButton(
                  onPressed: () {
                    // TODO: 반대 로직 처리
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