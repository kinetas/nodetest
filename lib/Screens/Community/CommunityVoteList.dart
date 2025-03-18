import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';
import 'CommunityVoteContent.dart'; // CommunityVoteContent import

class CommunityVoteList extends StatefulWidget {
  @override
  _CommunityVoteListState createState() => _CommunityVoteListState();
}

class _CommunityVoteListState extends State<CommunityVoteList> {
  List<dynamic> votes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVotes();
  }

  Future<void> fetchVotes() async {
    final url = 'http://27.113.11.48:3000/api/cVote/';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          votes = data['votes'] ?? []; // null이면 빈 리스트로 처리
          isLoading = false;
        });
      } else {
        print('Failed to load votes: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred while fetching votes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTitle(String? title, int maxLength) {
    if (title == null || title.isEmpty) {
      return '제목 없음'; // 기본값 설정
    }
    if (title.length > maxLength) {
      return '${title.substring(0, maxLength)}...';
    }
    return title;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '날짜 없음'; // 기본값 설정
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '잘못된 날짜'; // 날짜 형식 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue[400],
        ),
      )
          : Container(
        color: Colors.lightBlue[50],
        child: ListView.builder(
          itemCount: votes.length,
          itemBuilder: (context, index) {
            final vote = votes[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: CommunityVoteContent(
                        cNumber: vote['c_number'], // c_number 전달
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTitle(vote['c_title'], 20),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '삭제 날짜: ${_formatDate(vote['c_deletedate'])}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}