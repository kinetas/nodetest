import 'package:flutter/material.dart';

class MissionRecruitDetailScreen extends StatelessWidget {
  final bool isAuthor = false; // 👈 테스트용으로 글쓴이 여부 false
  final int maxParticipants = 1;
  final int acceptedCount = 0; // TODO: 서버 연동시 값 대체

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션구인', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          // 본문
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorRow(),
                const SizedBox(height: 12),
                Text(
                  '예) 미션같이 할 사람~',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('유저가 작성하는 미션에 대한 내용'),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 48),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAcceptDialog(context),
                      child: Text('수락'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[300],
                        foregroundColor: Colors.black,
                      ),
                    ),
                    Text('모집: $maxParticipants / 수락: $acceptedCount'),
                  ],
                ),
              ],
            ),
          ),
          Divider(),

          // 댓글 리스트 (수락/거절 제거됨)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildComment(),
              ],
            ),
          ),

          // 글쓴이만 보이는 하단 영역
          if (isAuthor) _buildAuthorOnlySection(),
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('유저 닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('2025/04/14 11:10 · 조회 00 · 추천 00', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildComment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
            const SizedBox(width: 8),
            Text('유저 닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('댓글 내용'),
        const SizedBox(height: 4),
        Text('04/14 11:12', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAuthorOnlySection() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(12),
      alignment: Alignment.centerLeft,
      child: Text('글쓴이만 보이는 영역', style: TextStyle(color: Colors.grey[700])),
    );
  }

  Widget _buildBottomInputBar() {
    return SafeArea(
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '메시지 입력',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.send)),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.play_arrow),
            label: Text('미션 보기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('수락 확인'),
        content: Text('정말 수락하시겠습니까?\n수락하신 이후에는 취소할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('미션 수락 완료!')),
              );
              // TODO: 서버에 수락 상태 반영
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
