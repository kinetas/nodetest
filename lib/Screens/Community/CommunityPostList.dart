import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';
import 'CommunityPostContent.dart'; // CommunityPostContent import

class CommunityPostList extends StatefulWidget {
  @override
  _CommunityPostListState createState() => _CommunityPostListState();
}

class _CommunityPostListState extends State<CommunityPostList> {
  List<dynamic> missions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    try {
      final url = 'http://54.180.54.31:3000/api/comumunity_missions/list';

      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          missions = data['missions'];
          isLoading = false;
        });
      } else {
        print('Failed to load missions: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred while fetching missions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getStatusLabel(String status) {
    if (status == 'acc') {
      return '매칭 완료'; // acc -> 매칭 완료
    } else if (status == 'match') {
      return '매칭 진행 중'; // match -> 매칭 진행 중
    } else {
      return '상태 알 수 없음';
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
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            final isMatchingCompleted = mission['cr_status'] == 'acc';

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  mission['cr_title'] ?? '제목 없음',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isMatchingCompleted
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                subtitle: Text(
                  _getStatusLabel(mission['cr_status']),
                  style: TextStyle(
                    color: isMatchingCompleted
                        ? Colors.grey
                        : Colors.lightBlue[700],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: isMatchingCompleted
                      ? Colors.grey
                      : Colors.lightBlue[400],
                ),
                onTap: isMatchingCompleted
                    ? null // 클릭 불가
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityPostContent(
                        crNum: mission['cr_num'], // cr_num 전달
                        crTitle: mission['cr_title'], // cr_title 전달
                        crStatus: mission['cr_status'], // cr_status 전달
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}