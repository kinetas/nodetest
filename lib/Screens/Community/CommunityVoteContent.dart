import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data'; // Uint8List를 사용하려면 추가
import '../../SessionCookieManager.dart';

class CommunityVoteContent extends StatefulWidget {
  final String cNumber; // 이전 화면에서 전달받은 c_number

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
  Uint8List? imageData; // 이미지 데이터
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVoteContent();
  }

  Future<void> fetchVoteContent() async {
    final url = 'http://54.180.54.31:3000/api/cVote/';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vote = data['votes'].firstWhere(
              (item) => item['c_number'] == widget.cNumber,
          orElse: () => null,
        );

        if (vote != null) {
          setState(() {
            title = vote['c_title'];
            content = vote['c_contents'];
            good = vote['c_good'];
            bad = vote['c_bad'];
            deletedate = vote['c_deletedate'];
            if (vote['c_image'] != null && vote['c_image']['data'] != null) {
              imageData = Uint8List.fromList(
                  List<int>.from(vote['c_image']['data']));
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
      print('Error fetching vote content: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> postVote(String action) async {
    final url = 'http://54.180.54.31:3000/api/cVote/action';
    final body = json.encode({
      "c_number": widget.cNumber,
      "action": action,
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
          SnackBar(content: Text('투표 반영에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Error posting vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  void showImageDialog(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.memory(imageData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('투표 상세보기'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "찬성: $good, 반대: $bad",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                "삭제 예정일: ${DateTime.parse(deletedate).toLocal()}",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (imageData != null)
                GestureDetector(
                  onTap: () => showImageDialog(imageData!),
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
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => postVote('good'),
                    child: Text('찬성'),
                  ),
                  ElevatedButton(
                    onPressed: () => postVote('bad'),
                    child: Text('반대'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}