import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

class CommunityPostContent extends StatefulWidget {
  final String crNum; // 필수 전달 인자
  final String crTitle; // 제목
  final String crStatus; // 상태

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

  // 데이터를 가져오고 crNum으로 필터링
  Future<void> fetchPostContent() async {
    final url = 'http://54.180.54.31:3000/api/comumunity_missions/list';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['missions'];

        // crNum으로 데이터 필터링
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

  // 미션 수락
  Future<void> acceptMission() async {
    final url = 'http://54.180.54.31:3000/api/comumunity_missions/accept';
    final body = json.encode({"cr_num": widget.crNum});

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션이 수락되었습니다!')),
        );
        Navigator.pop(context); // 이전 화면으로 돌아가기
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
    if (status == 'acc') {
      return '매칭 완료'; // acc는 매칭 완료
    } else if (status == 'match') {
      return '매칭 중'; // match는 매칭 중
    } else {
      return '상태 알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatched = widget.crStatus == 'acc'; // 매칭 완료 상태 여부

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 앱 바에 아무것도 표시하지 않음
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  widget.crTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // 상태
                Text(
                  _getStatusLabel(widget.crStatus),
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                SizedBox(height: 8),

                // 기한
                Text(
                  "미션 기한: $deadline",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),

                // 내용
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 수락 버튼
          Positioned(
            bottom: 16,
            right: 16,
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
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  await acceptMission();
                }
              },
              child: Text('수락하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMatched
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                minimumSize: Size(120, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}