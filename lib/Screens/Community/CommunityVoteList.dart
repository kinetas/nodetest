import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';

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
    final url = 'http://54.180.54.31:3000/api/cVote/';

    try {
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          votes = data['votes'];
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

  String _formatTitle(String title, int maxLength) {
    if (title.length > maxLength) {
      return '${title.substring(0, maxLength)}...';
    }
    return title;
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티 투표 목록'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: votes.length,
        itemBuilder: (context, index) {
          final vote = votes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                    _formatTitle(vote['c_title'], 20), // 제목 출력 및 길이 제한
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '삭제 날짜: ${_formatDate(vote['c_deletedate'])}', // 삭제 날짜 출력
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}