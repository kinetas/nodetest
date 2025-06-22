import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../SessionTokenManager.dart';
import 'Comment.dart';

class FreeBoardDetailScreen extends StatefulWidget {
  final String crNum;
  const FreeBoardDetailScreen({super.key, required this.crNum});

  @override
  State<FreeBoardDetailScreen> createState() => _FreeBoardDetailScreenState();
}

class _FreeBoardDetailScreenState extends State<FreeBoardDetailScreen> {
  bool isAuthor = false;
  Map<String, dynamic>? post;
  bool isLoading = true;
  bool hasRecommended = false;
  int commentCount = 0;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/getOneCommunity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['communities'];
      setState(() {
        post = data;
        hasRecommended = false;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 로딩 실패: ${response.statusCode}')),
      );
    }
  }

  Future<void> recommendPost() async {
    if (hasRecommended) return;
    final token = await SessionTokenManager.getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/recommendCommunity'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['success'] == true) {
      setState(() {
        hasRecommended = true;
        post!['recommended_num'] = (post!['recommended_num'] ?? 0) + 1;
      });
    }
  }

  void updateCommentCount(int count) {
    setState(() {
      commentCount = count;
    });
  }

  void showImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.memory(imageBytes, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('자유게시판', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostDetail(),
                  const SizedBox(height: 20),
                  Divider(height: 32, color: Colors.grey[300]),
                  Text('댓글 $commentCount개', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CommentSection(
                    crNum: widget.crNum,
                    onCommentCountChanged: updateCommentCount,
                  ),
                ],
              ),
            ),
          ),
          _buildCommentInputBar(),
        ],
      ),
    );
  }

  Widget _buildPostDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAuthorRow(),
        const SizedBox(height: 12),
        Text(post?['cr_title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(post?['contents'] ?? '', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        if (post?['image'] != null)
          GestureDetector(
            onTap: () => showImageDialog(base64Decode(post!['image'])),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: MemoryImage(base64Decode(post!['image'])),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(post?['u_id'] ?? '유저', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Text(
              '${(post?['maded_time'] ?? '').toString().split("T")[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Text('조회 ${post?['hits'] ?? 0}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            InkWell(
              onTap: recommendPost,
              child: Row(
                children: [
                  Icon(
                    hasRecommended ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: hasRecommended ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('${post?['recommended_num'] ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  await CommentSection.sendCommentExternally(text, widget.crNum);
                  _commentController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}