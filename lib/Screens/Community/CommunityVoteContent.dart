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
    final url = 'http://54.180.54.31:3000/api/cVote/';

    try {
      final response = await SessionCookieManager.get(url);

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vote = data['votes']?.firstWhere(
              (item) => item['c_number'] == widget.cNumber,
          orElse: () => null,
        );

        if (vote != null) {
          print('Vote found: $vote');
          setState(() {
            title = vote['c_title'] ?? "제목 없음";
            content = vote['c_contents'] ?? "내용 없음";
            good = vote['c_good'] ?? 0;
            bad = vote['c_bad'] ?? 0;
            deletedate = vote['c_deletedate'] ?? "날짜 없음";

            // 이미지 데이터 처리
            if (vote['c_image'] != null && vote['c_image']['data'] != null) {
              try {
                imageData = Uint8List.fromList(List<int>.from(vote['c_image']['data']));
                print('Image data processed successfully');
              } catch (e) {
                print('Error processing image data: $e');
                imageData = null;
              }
            } else {
              print('No image data found');
              imageData = null;
            }

            // 삭제 날짜 처리
            try {
              if (deletedate != "날짜 없음") {
                deletedate = DateTime.parse(deletedate)
                    .toLocal()
                    .toString()
                    .split(' ')[0];
              }
            } catch (e) {
              print('Error parsing date: $e');
              deletedate = "날짜 없음";
            }

            isLoading = false;
          });
        } else {
          print('No matching vote found');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('해당 투표 정보를 찾을 수 없습니다.')),
          );
        }
      } else {
        print('Failed to fetch vote content: Status code ${response.statusCode}');
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

  Future<void> fetchImage(String imageUrl) async {
    print('Starting to fetch image from: $imageUrl');
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      print('Image response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Image fetched successfully');
        setState(() {
          imageData = Uint8List.fromList(response.data);
        });
      } else {
        print('Failed to load image: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }

  void showImageDialog(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.memory(
              imageData,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> postVote(String action) async {
    final url = 'http://54.180.54.31:3000/api/cVote/action';
    final body = json.encode({
      "c_number": widget.cNumber,
      "action": action,
    });

    setState(() {
      isButtonDisabled = true; // 버튼 비활성화
    });

    try {
      final response = await SessionCookieManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}'); // 응답 내용 출력

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
          SnackBar(
            content: Text('투표 반영에 실패했습니다. 상태 코드: ${response.statusCode}'),
          ),
        );
        setState(() {
          isButtonDisabled = false; // 실패 시 버튼 다시 활성화
        });
      }
    } catch (e) {
      print('Error posting vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        isButtonDisabled = false; // 실패 시 버튼 다시 활성화
      });
    }
  }

  @override
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
              // 제목
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // 내용
              Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // 찬성/반대 카운트
              Text(
                "찬성: $good, 반대: $bad",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),

              // 삭제 예정일
              Text(
                "삭제 예정일: $deletedate",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),

              // 이미지 출력
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
                )
              else
                Text(
                  '이미지가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),

              // 찬성/반대 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:
                    isButtonDisabled ? null : () => postVote('good'),
                    child: Text('찬성'),
                  ),
                  ElevatedButton(
                    onPressed:
                    isButtonDisabled ? null : () => postVote('bad'),
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