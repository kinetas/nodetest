import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';

class CommentSection extends StatefulWidget {
  final String crNum;
  const CommentSection({super.key, required this.crNum});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<dynamic> comments = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await http.post(
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/getCommunityComments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        comments = data['comments'] ?? [];
      });
    }
  }

  Future<void> writeComment() async {
    final token = await SessionTokenManager.getToken();
    if (token == null || _controller.text.trim().isEmpty) return;

    final response = await http.post(
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/writeComment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cr_num': widget.crNum,
        'comment': _controller.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      _controller.clear();
      fetchComments();
    }
  }

  Future<void> recommendComment(String ccNum) async {
    await http.post(
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/recommendComment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cc_num': ccNum}),
    );
    fetchComments();
  }

  Future<void> deleteComment(String ccNum) async {
    await http.post(
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/deleteComment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cc_num': ccNum}),
    );
    fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final comment in comments) _buildCommentTile(comment),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildCommentTile(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment['user_nickname'] ?? '유저', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(comment['comment'] ?? ''),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => recommendComment(comment['cc_num']),
                      child: Text('추천 ${comment['recommended_num'] ?? 0}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    Text(
                      comment['created_time']?.split('T')[0] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
            onPressed: () => deleteComment(comment['cc_num']),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: writeComment,
              icon: const Icon(Icons.send, color: Colors.lightBlue),
            ),
          ],
        ),
      ),
    );
  }
}