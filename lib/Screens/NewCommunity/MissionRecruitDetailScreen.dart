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
  bool isMatched = false;
  int maxParticipants = 1;
  int acceptedCount = 0;

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
          utf8.decode(base64.decode(base64.normalize(token.split('.')[1])))
      );
      currentUserId = payload['u_id'];
    }

    final response = await SessionTokenManager.get(
      'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['missions'];
      final match = data.firstWhere((m) => m['cr_num'] == widget.crNum, orElse: () => null);
      if (match != null) {
        final m1Status = match['m1_status']?.toString().toLowerCase();
        final m2Status = match['m2_status']?.toString().toLowerCase();

        setState(() {
          mission = match;
          isAuthor = currentUserId == match['u_id'];
          isMatched = m1Status == 'accepted' || m2Status == 'accepted';
          isLoading = false;
        });
      }
    }
  }

  Future<void> acceptMission() async {
    final token = await SessionTokenManager.getToken();
    if (token == null) return;

    final url = Uri.parse('http://27.113.11.48:3000/nodetest/api/comumunity_missions/accept');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cr_num': widget.crNum}),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '미션 수락 완료!')),
      );
      fetchMissionDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수락 실패: ${result['message'] ?? response.statusCode}')),
      );
    }
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [_buildComment()],
            ),
          ),
          if (isAuthor) _buildAuthorOnlySection(),
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
          Text(mission!['cr_title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: (isAuthor || isMatched) ? null : _showAcceptDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text('수락'),
              ),
              Text('상태: ${isAuthor ? '내가 작성한 글' : isMatched ? '이미 매칭됨' : '수락 가능'}'),
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
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mission?['u_id'] ?? '작성자', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${(mission?['maded_time'] ?? '').toString().split("T")[0]} · 조회 ${mission?['hits']} · 추천 ${mission?['recommended_num']}',
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
            const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
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

  Widget _buildAuthorOnlySection() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(12),
      alignment: Alignment.centerLeft,
      child: const Text('글쓴이만 보이는 영역', style: TextStyle(color: Colors.grey)),
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
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('미션 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
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
}