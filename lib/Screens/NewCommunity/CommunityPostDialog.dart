//홈 화면에서 최신게시글 선택했을때 보이는 화면 입니다.
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class CommunityPostDialog extends StatefulWidget {
  final String crNum;
  final String crTitle;
  final String crStatus;

  const CommunityPostDialog({
    required this.crNum,
    required this.crTitle,
    required this.crStatus,
    Key? key,
  }) : super(key: key);

  @override
  State<CommunityPostDialog> createState() => _CommunityPostDialogState();
}

class _CommunityPostDialogState extends State<CommunityPostDialog> {
  String deadline = "로딩 중...";
  String content = "로딩 중...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostContent();
  }

  Future<void> fetchPostContent() async {
    final url = 'http://13.125.65.151:3000/nodetest/api/comumunity_missions/list';
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

  String _getStatusLabel(String status) {
    if (status == 'acc') return '매칭 완료';
    if (status == 'match') return '매칭 중';
    return '상태 알 수 없음';
  }

  @override
  Widget build(BuildContext context) {
    // 화면 사이즈에 따라 Dialog 최대 크기 제한
    final Size screen = MediaQuery.of(context).size;
    final double dialogWidth = screen.width * 0.92;
    final double dialogMaxHeight = screen.height * 0.80;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: screen.width * 0.04, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(22),
          child: isLoading
              ? SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(color: Colors.lightBlue[400]),
            ),
          )
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단: 타이틀 & 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '게시글 상세',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[700]),
                      splashRadius: 22,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // 상태 + 마감일
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.crStatus == 'acc'
                            ? Colors.grey[200]
                            : Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(widget.crStatus),
                        style: TextStyle(
                          color: widget.crStatus == 'acc'
                              ? Colors.grey[600]
                              : Colors.lightBlue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(Icons.event, color: Colors.lightBlue, size: 15),
                    Text(
                      '마감일: $deadline',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 17),
                // 제목
                Text(
                  widget.crTitle,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),
                // 본문
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
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
