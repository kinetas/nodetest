import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../SessionTokenManager.dart';
import 'Comment.dart';

class MissionRecruitDetailScreen extends StatefulWidget {
  final String crNum;

  const MissionRecruitDetailScreen({Key? key, required this.crNum}) : super(key: key);

  @override
  State<MissionRecruitDetailScreen> createState() => _MissionRecruitDetailScreenState();
}

class _MissionRecruitDetailScreenState extends State<MissionRecruitDetailScreen> {
  Map<String, dynamic>? mission;
  bool isLoading = true;
  bool isAuthor = false;
  bool hasRecommended = false;
  final TextEditingController _commentController = TextEditingController();
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMissionDetail();
  }

  Future<void> fetchMissionDetail() async {
    final token = await SessionTokenManager.getToken();
    String? currentUserId;

    if (token != null) {
      final payload = json.decode(
          utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))));
      currentUserId = payload['u_id'];
    }

    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/comumunity_missions/list',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['missions'];
      final match = data.firstWhere((m) => m['cr_num'] == widget.crNum, orElse: () => null);
      if (match != null) {
        setState(() {
          mission = match;
          isAuthor = currentUserId == match['u_id'];
          isLoading = false;
        });
      }
    }
  }

  Future<void> acceptMission() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) return;

    final url = Uri.parse('http://13.125.65.151:3000/nodetest/api/comumunity_missions/accept');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    final result = jsonDecode(response.body);
    String message = result['message'] ?? '응답 없음';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(response.statusCode == 200 && result['success'] == true ? '미션 수락 완료' : '수락 실패'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              fetchMissionDetail();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수락 확인'),
        content: const Text('정말 수락하시겠습니까?\n수락하신 이후에는 취소할 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              acceptMission();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
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
        mission!['recommended_num'] = (mission!['recommended_num'] ?? 0) + 1;
      });
    }
  }

  void updateCommentCount(int count) {
    setState(() {
      commentCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || mission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('미션구인')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('미션구인', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (isAuthor)
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          _buildPostDetail(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Text('댓글 $commentCount개', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CommentSection(
                  crNum: widget.crNum,
                  onCommentCountChanged: updateCommentCount,
                ),
              ],
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
          Text(mission!['cr_title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(mission!['contents'] ?? ''),
          const SizedBox(height: 12),
          if (mission!['image'] != null)
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 48),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAcceptDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('참여'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            mission?['u_id'] ?? '작성자',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Text(
              '${(mission?['maded_time'] ?? '').toString().split("T")[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              '조회 ${mission?['hits'] ?? 0}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                InkWell(
                  onTap: recommendPost,
                  child: Icon(
                    hasRecommended ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: hasRecommended ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${mission?['recommended_num'] ?? 0}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
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
              onPressed: () async {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  await CommentSection.sendCommentExternally(text, widget.crNum);
                  _commentController.clear();
                }
              },
              icon: const Icon(Icons.send, color: Colors.lightBlue),
            ),
          ],
        ),
      ),
    );
  }
}