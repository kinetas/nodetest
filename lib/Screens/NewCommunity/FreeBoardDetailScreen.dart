import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';

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
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/getOneCommunity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ 추가
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['communities'];
      setState(() {
        post = data;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 로딩 실패: ${response.statusCode}')),
      );
    }
  }

  Future<void> recommendPost() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/recommendCommunity'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '추천 완료!')),
      );
      fetchPostDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추천 실패: ${result['message'] ?? response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('자유게시판')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('자유게시판', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: const BackButton(),
        actions: [
          if (isAuthor)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPostDetail(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [_buildComment()],
            ),
          ),
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildPostDetail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorRow(),
          const SizedBox(height: 12),
          Text(
            post?['cr_title'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(post?['contents'] ?? ''),
          const SizedBox(height: 12),
          if (post?['image'] != null)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: MemoryImage(base64Decode(post!['image'])),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined),
                onPressed: recommendPost,
              ),
              const Icon(Icons.notifications_none),
              const Icon(Icons.bookmark_border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post?['u_id'] ?? '유저', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${(post?['maded_time'] ?? '').toString().split("T")[0]} · 조회 ${post?['hits']} · 추천 ${post?['recommended_num']}',
              style: const TextStyle(fontSize: 12),
            ),
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
                children: const [
                  Text('유저 닉네임', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('댓글 내용'),
                  SizedBox(height: 4),
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
            const Icon(Icons.more_vert, size: 16, color: Colors.grey),
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.lightBlue),
            ),
          ],
        ),
      ),
    );
  }
}