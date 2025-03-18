import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../SessionCookieManager.dart';

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
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchVoteContent();
  }

  Future<void> fetchVoteContent() async {
    final url = 'http://27.113.11.48:3000/api/cVote/';

    try {
      final response = await SessionCookieManager.get(url);

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
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('해당 투표 정보를 찾을 수 없습니다.')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 가져오지 못했습니다.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> postVote(String action) async {
    final url = 'http://27.113.11.48:3000/api/cVote/action';
    final body = json.encode({
      "c_number": widget.cNumber,
      "action": action,
    });

    setState(() {
      isButtonDisabled = true;
    });

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표가 반영되었습니다.')),
        );
        if (action == 'good') {
          setState(() {
            good += 1;
          });
        } else if (action == 'bad') {
          setState(() {
            bad += 1;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('투표 반영에 실패했습니다. 상태 코드: ${response.statusCode}')),
        );
        setState(() {
          isButtonDisabled = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          '투표 상세보기',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    content,
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "찬성: $good, 반대: $bad",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "삭제 예정일: $deletedate",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 16),
                  if (imageData != null)
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.memory(imageData!),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            imageData!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      '이미지가 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isButtonDisabled ? null : () => postVote('good'),
                        child: Text('찬성'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isButtonDisabled ? null : () => postVote('bad'),
                        child: Text('반대'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}