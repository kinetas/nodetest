import 'package:flutter/material.dart';

class FreeBoardDetailScreen extends StatelessWidget {
  final bool isAuthor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자유게시판', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: BackButton(),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorRow(),
                const SizedBox(height: 12),
                Text(
                  '글 제목',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('글 내용'),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 48),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.thumb_up_alt_outlined),
                    Icon(Icons.notifications_none),
                    Icon(Icons.bookmark_border),
                  ],
                ),
              ],
            ),
          ),
          Divider(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildComment(),
              ],
            ),
          ),

          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('유저 닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('댓글 내용'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('추천 00', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('04/14 11:12', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBottomInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '메시지 입력',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send, color: Colors.lightBlue),
            ),
          ],
        ),
      ),
    );
  }
}
