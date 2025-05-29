import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class CommunityPostContent extends StatefulWidget {
  final String crNum;
  final String crTitle;
  final String crStatus;

  CommunityPostContent({
    required this.crNum,
    required this.crTitle,
    required this.crStatus,
  });

  @override
  _CommunityPostContentState createState() => _CommunityPostContentState();
}

class _CommunityPostContentState extends State<CommunityPostContent> {
  String deadline = "로딩 중...";
  String content = "로딩 중...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostContent();
  }

  Future<void> fetchPostContent() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list';
    try {
      final response = await SessionTokenManager.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['missions'];
        final mission = data.firstWhere(
              (mission) => mission['cr_num'] == widget.crNum,
          orElse: () => null,
        );
        if (mission != null) {
          setState(() {
            deadline = mission['deadline'] ?? '기한 없음';
            content = mission['contents'] ?? '내용 없음';
            isLoading = false;
          });
        } else {
          setState(() {
            content = '해당 미션을 찾을 수 없습니다.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          content = '데이터를 가져오는데 실패했습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        content = '오류가 발생했습니다. 다시 시도해주세요.';
        isLoading = false;
      });
    }
  }

  Future<void> acceptMission() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/accept';
    final body = json.encode({"cr_num": widget.crNum});
    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션이 수락되었습니다!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션 수락에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  String _getStatusLabel(String status) {
    if (status == 'acc') return '매칭 완료';
    if (status == 'match') return '매칭 중';
    return '상태 알 수 없음';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatched = widget.crStatus == 'acc';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: const Text(
          '게시글 상세',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]))
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상태/마감일 라벨 (모던하게)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? Colors.grey[200]
                            : Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(widget.crStatus),
                        style: TextStyle(
                          color: isMatched
                              ? Colors.grey[600]
                              : Colors.lightBlue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFBFD7ED), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.lightBlue, size: 15),
                          SizedBox(width: 5),
                          Text(
                            '마감일',
                            style: TextStyle(
                              color: Colors.lightBlue[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            deadline,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 제목
                Text(
                  widget.crTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 18),
                // 본문(더 넓고 자연스럽게, 배경톤만 부드럽게)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      height: 1.7,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                SizedBox(height: 38),
                // 미션 수락 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isMatched
                        ? null
                        : () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('미션 수락'),
                          content: Text('미션을 수락하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text('취소')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text('확인')),
                          ],
                        ),
                      );
                      if (result == true) {
                        await acceptMission();
                      }
                    },
                    child: Text(
                      '미션 수락하기',
                      style: TextStyle(fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMatched
                          ? Colors.grey[400]
                          : Colors.lightBlue[400],
                      minimumSize: Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
