import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../SessionTokenManager.dart';

class CommunityVoteContent extends StatefulWidget {
  final String cNumber;

  CommunityVoteContent({required this.cNumber});

  @override
  _CommunityVoteContentState createState() => _CommunityVoteContentState();
}

class _CommunityVoteContentState extends State<CommunityVoteContent> {
  String title = "로딩 중...";
  String content = "로딩 중...";
  int good = 0;
  int bad = 0;
  String deletedate = "로딩 중...";
  Uint8List? imageData;
  bool isLoading = true;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    fetchVoteContent();
  }

  Future<void> fetchVoteContent() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/cVote/';

    try {
      final response = await SessionTokenManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vote = data['votes']?.firstWhere(
              (item) => item['c_number'] == widget.cNumber,
          orElse: () => null,
        );

        if (vote != null) {
          setState(() {
            title = vote['c_title'] ?? "제목 없음";
            content = vote['c_contents'] ?? "내용 없음";
            good = vote['c_good'] ?? 0;
            bad = vote['c_bad'] ?? 0;
            deletedate = vote['c_deletedate'] ?? "날짜 없음";

            if (vote['c_image'] != null && vote['c_image']['data'] != null) {
              try {
                imageData = Uint8List.fromList(List<int>.from(vote['c_image']['data']));
              } catch (e) {
                imageData = null;
              }
            } else {
              imageData = null;
            }

            try {
              if (deletedate != "날짜 없음") {
                deletedate = DateTime.parse(deletedate)
                    .toLocal()
                    .toString()
                    .split(' ')[0];
              }
            } catch (e) {
              deletedate = "날짜 없음";
            }

            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('해당 투표 정보를 찾을 수 없습니다.')),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 가져오지 못했습니다.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> postVote(String action) async {
    final url = 'http://27.113.11.48:3000/api/cVote/action';
    final body = json.encode({
      "c_number": widget.cNumber,
      "action": action,
    });

    setState(() => isButtonDisabled = true);

    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표가 반영되었습니다.')),
        );
        setState(() {
          if (action == 'good') {
            good += 1;
          } else if (action == 'bad') {
            bad += 1;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표 반영에 실패했습니다. 상태 코드: ${response.statusCode}')),
        );
        setState(() => isButtonDisabled = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
      setState(() => isButtonDisabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: const Text(
          '투표 상세보기',
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
                // 마감(삭제예정일) 라벨
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFBFD7ED), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event, color: Colors.lightBlue, size: 16),
                          SizedBox(width: 5),
                          Text(
                            '삭제 예정일',
                            style: TextStyle(
                              color: Colors.lightBlue[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            deletedate,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined,
                              color: Colors.lightBlue, size: 16),
                          SizedBox(width: 4),
                          Text('$good',
                              style: TextStyle(
                                  color: Colors.lightBlue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          SizedBox(width: 10),
                          Icon(Icons.thumb_down_alt_outlined,
                              color: Colors.redAccent, size: 16),
                          SizedBox(width: 4),
                          Text('$bad',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 제목
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                // 본문(더 넓고 자연스럽게)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                SizedBox(height: 20),
                // 이미지
                if (imageData != null)
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Image.memory(imageData!),
                        ),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          imageData!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    alignment: Alignment.center,
                    height: 90,
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('이미지가 없습니다.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                SizedBox(height: 18),
                // 투표 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isButtonDisabled
                            ? null
                            : () => postVote('good'),
                        icon: Icon(Icons.thumb_up_alt_outlined),
                        label: Text('찬성'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isButtonDisabled
                            ? null
                            : () => postVote('bad'),
                        icon: Icon(Icons.thumb_down_alt_outlined),
                        label: Text('반대'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
