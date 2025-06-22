import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';
import 'package:intl/intl.dart';

class CommentSection extends StatefulWidget {
  final String crNum;
  final Function(int)? onCommentCountChanged;

  const CommentSection({
    super.key,
    required this.crNum,
    this.onCommentCountChanged,
  });

  @override
  State<CommentSection> createState() => CommentSectionState();

  /// ✅ 외부에서 호출 가능한 댓글 등록 메서드
  static Future<void> sendCommentExternally(String content, String crNum) async {
    final token = await SessionTokenManager.getToken();
    if (token == null) {
      print('❌ 토큰 없음');
      return;
    }

    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/writeComment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cr_num': crNum,
        'comment': content,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ 댓글 등록 성공');
      _lastStateInstance?.fetchComments();
    } else {
      print('❌ 댓글 등록 실패: ${response.statusCode}');
    }
  }

  /// ✅ 마지막 상태 인스턴스를 캐싱하여 외부에서 접근 가능하게 함
  static CommentSectionState? _lastStateInstance;
}

class CommentSectionState extends State<CommentSection> {
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    CommentSection._lastStateInstance = this;
    fetchComments();
  }

  @override
  void dispose() {
    if (CommentSection._lastStateInstance == this) {
      CommentSection._lastStateInstance = null;
    }
    super.dispose();
  }

  Future<void> fetchComments() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) {
      print('❌ 토큰이 없음');
      return;
    }

    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/getCommunityComments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> newComments = data['comments'] ?? [];
      setState(() {
        comments = newComments;
      });

      if (widget.onCommentCountChanged != null) {
        widget.onCommentCountChanged!(newComments.length);
      }
    } else {
      print('❌ 댓글 불러오기 실패: ${response.statusCode}');
    }
  }

  Future<void> recommendComment(String ccNum) async {
    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/recommendComment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cc_num': ccNum}),
    );

    if (response.statusCode == 200) {
      fetchComments();
    } else {
      print('❌ 댓글 추천 실패: ${response.statusCode}');
    }
  }

  Future<void> deleteComment(String ccNum) async {
    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/deleteComment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cc_num': ccNum}),
    );

    if (response.statusCode == 200) {
      fetchComments();
    } else {
      print('❌ 댓글 삭제 실패: ${response.statusCode}');
    }
  }

  String formatDate(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final comment in comments) _buildCommentTile(comment),
      ],
    );
  }

  Widget _buildCommentTile(dynamic comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment['user_nickname'] ?? '유저',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(comment['comment'] ?? ''),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => recommendComment(comment['cc_num']),
                        child: Text('👍 ${comment['recommended_num'] ?? 0}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                      const SizedBox(width: 12),
                      Text(formatDate(comment['created_time']),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
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
}