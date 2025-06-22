import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../SessionTokenManager.dart';

class MissionVoteDetailScreen extends StatefulWidget {
  final String cNum;


  const MissionVoteDetailScreen({Key? key, required this.cNum}) : super(key: key);

  @override
  State<MissionVoteDetailScreen> createState() => _MissionVoteDetailScreenState();
}

class _MissionVoteDetailScreenState extends State<MissionVoteDetailScreen> {
  Map<String, bool> votedMap = {};
  List<Map<String, dynamic>> votes = [];

  bool isLoading = true;
  int currentIndex = 0;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    fetchVotes();
  }

  Future<void> fetchVotes() async {
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/cVote',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint("✅ 전체 응답: ${response.body}");

      if (data['success']) {
        final allVotes = List<Map<String, dynamic>>.from(data['votes']);
        final index = allVotes.indexWhere((v) => v['c_number'] == widget.cNum);
        setState(() {
          votes = allVotes;
          currentIndex = index != -1 ? index : 0;
          isLoading = false;
        });
      }
    } else {
      debugPrint("❌ 상태코드 ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = PageController(initialPage: 0);

    return NotificationListener<ScrollNotification>(
      // onNotification: (notification) {
      //   if (notification is ScrollUpdateNotification) {
      //     if (notification.metrics.pixels < _lastOffset) {
      //       controller.jumpToPage(0); // 이전 방향 스크롤 방지
      //       return true;
      //     }
      //     _lastOffset = notification.metrics.pixels;
      //   }
      //   return false;
      // },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemCount: votes.length - currentIndex,
        onPageChanged: (index) {
          final cNumber = votes[currentIndex + index]['c_number'];
          debugPrint("📄 페이지 전환 → index: $index, c_number: $cNumber");
        },
        itemBuilder: (context, index) {
          final vote = votes[currentIndex + index];
          return MissionVoteDetailCard(
            vote: vote,
            hasVoted: votedMap[vote['c_number']] ?? false,
            onVoted: (String cNum) {
              setState(() {
                votedMap[cNum] = true;
                votedMap[cNum] = true;
              });
            },
          );
        },
      )
    );
  }
}

class MissionVoteDetailCard extends StatefulWidget {
  final Map<String, dynamic> vote;
  final bool hasVoted;
  final Function(String cNumber) onVoted;
  @override
  State<MissionVoteDetailCard> createState() => _MissionVoteDetailCardState();

  const MissionVoteDetailCard({
    Key? key,
    required this.vote,
    required this.hasVoted,
    required this.onVoted,
  }) : super(key: key);
}

class _MissionVoteDetailCardState extends State<MissionVoteDetailCard> {
  late Map<String, dynamic> voteData;
  //bool hasVoted = false;
  bool isVoting = false;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    voteData = widget.vote;

    final deadline = DateTime.tryParse(voteData['c_deletedate'] ?? '');
    isExpired = deadline != null && DateTime.now().isAfter(deadline);

    // 이미지가 없으면 상세 데이터 다시 요청
    if (voteData['c_image'] == null) {
      fetchVoteDetail();
    }
  }
  Future<void> fetchVoteDetail() async {
    final cNumber = voteData['c_number'];
    final response = await SessionTokenManager.get(
      'http://13.125.65.151:3000/nodetest/api/cVote/details?c_number=$cNumber',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          voteData = {
            ...voteData, // 기존 값 유지
            ...data['vote'], // 서버 응답으로 덮어쓰기
          };
        });
      }
    } else {
      debugPrint('❌ 상세 투표 가져오기 실패: ${response.statusCode}');
    }
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

  Future<void> sendVote(String action) async {
    if (isVoting || widget.hasVoted || isExpired) return;

    final cNum = voteData['c_number'];
    if (cNum == null) {
      debugPrint("❗️ voteData에 c_number 없음 → voteData: $voteData");
      return;
    }

    setState(() => isVoting = true);

    debugPrint("🗳️ 투표 시도 → c_number: $cNum, action: $action");

    final response = await SessionTokenManager.post(
      'http://13.125.65.151:3000/nodetest/api/cVote/action',
      body: json.encode({
        "c_number": cNum,
        "action": action,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        debugPrint("✅ 투표 성공 → c_number: $cNum, action: $action");
        setState(() {
          voteData = data['vote'];
        });
        widget.onVoted(cNum);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('투표 완료'),
            content: Text(action == 'good' ? '찬성 투표가 반영되었습니다!' : '반대 투표가 반영되었습니다!'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
            ],
          ),
        );
      }
    } else {
      debugPrint("❌ 투표 실패 → c_number: $cNum, status: ${response.statusCode}");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: const Text('투표에 실패했습니다. 잠시 후 다시 시도해주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    }

    setState(() => isVoting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 유저 정보
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
                    Text(voteData['u_id'] ?? '익명', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${voteData['c_deletedate']?.toString().split("T")[0]} · 추천 ${voteData['c_good'] ?? 0} · 반대 ${voteData['c_bad'] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 제목
            Text(
              voteData['c_title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 내용
            Text(
              voteData['c_contents'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // 이미지
            if (voteData['c_image'] != null)
              Builder(
                builder: (context) {
                  Uint8List? imageBytes;
                  try {
                    if (voteData['c_image'] is String) {
                      // base64 문자열일 경우
                      imageBytes = base64Decode(voteData['c_image']);
                    } else if (voteData['c_image']['data'] != null) {
                      // Buffer 객체일 경우
                      final bufferList = List<int>.from(voteData['c_image']['data']);
                      imageBytes = Uint8List.fromList(bufferList);
                    }
                    debugPrint("🧾 이미지 디코딩 성공");
                  } catch (e) {
                    debugPrint("❌ 이미지 디코딩 실패: $e");
                  }

                  if (imageBytes != null) {
                    return GestureDetector(
                      onTap: () => showImageDialog(imageBytes!),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: MemoryImage(imageBytes),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Text("⚠️ 이미지 로딩 실패");
                  }
                },
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 48),
              ),
            const SizedBox(height: 30),

            // 버튼
            if (isExpired)
              const Center(
                child: Text(
                  "⚠️ 투표 마감일이 지나 투표할 수 없습니다.",
                  style: TextStyle(color: Colors.red),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (isVoting || widget.hasVoted) ? null : () => sendVote('good'),
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
                    onPressed: (isVoting || widget.hasVoted) ? null : () => sendVote('bad'),
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