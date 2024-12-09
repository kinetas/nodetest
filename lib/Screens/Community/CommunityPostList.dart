import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionCookieManager.dart';
import 'CommunityPostContent.dart'; // CommunityPostContent를 import

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

      // Static 메서드를 클래스 이름을 통해 호출
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the missions list
        setState(() {
          missions = data['missions'];
          isLoading = false;
        });
      } else {
        // Handle errors
        print('Failed to load missions: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return ListTile(
          title: Text(mission['cr_title'] ?? '제목 없음'),
          subtitle: Text(_getStatusLabel(mission['cr_status'])), // 상태 변환하여 표시
          onTap: () {
            // 상세 화면으로 이동
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
        );
      },
    );
  }
}