import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:http/http.dart' as http;

class YouAndIMissionList extends StatefulWidget {
  final String rId;
  final String u2Id;

  YouAndIMissionList({required this.rId, required this.u2Id});

  @override
  _YouAndIMissionListState createState() => _YouAndIMissionListState();
}

class _YouAndIMissionListState extends State<YouAndIMissionList> {
  List<Map<String, dynamic>> missions = []; // 모든 미션 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchMissions(); // API 호출
  }

  Future<void> fetchMissions() async {
    try {
      // 서버 호출
      final response = await http.get(
        Uri.parse('http://13.125.65.151:3000/nodetest/api/missions?rid=${widget.rId}&u2id=${widget.u2Id}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 데이터를 저장
        if (responseData['missions'] != null && responseData['missions'] is List) {
          setState(() {
            missions = (responseData['missions'] as List<dynamic>)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("You & I Mission List")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (missions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("You & I Mission List")),
        body: Center(child: Text("미션 없음")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("You & I Mission List")),
      body: ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(mission['m_title'] ?? '제목 없음'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('마감 기한: ${mission['m_deadline'] ?? '알 수 없음'}'),
                  Text('미션 상태: ${mission['m_status'] ?? '알 수 없음'}'),
                ],
              ),
              onTap: () {
                print('미션 클릭: ${mission['m_title']}');
                // 다른 화면으로 이동하거나 상세 작업 처리
              },
            ),
          );
        },
      ),
    );
  }
}