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

  Future<void> fetchPostContent() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/list';

    try {
      final response = await SessionCookieManager.get(url);

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
      final response = await SessionCookieManager.post(
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
    if (status == 'acc') {
      return '매칭 완료';
    } else if (status == 'match') {
      return '매칭 중';
    } else {
      return '상태 알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatched = widget.crStatus == 'acc';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue[300]!,
                  Colors.lightBlue[50]!,
                ],
              ),
            ),
          ),
          isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.lightBlue[400],
            ),
          )
              : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.crTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getStatusLabel(widget.crStatus),
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "미션 기한: $deadline",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            content,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
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
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
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
                          : Colors.lightBlue[400],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}