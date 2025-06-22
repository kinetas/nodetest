import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../SessionTokenManager.dart';

class MyCompleteMissionList extends StatefulWidget {
  @override
  _MyCompleteMissionListState createState() => _MyCompleteMissionListState();
}

// ... import 생략 동일

class _MyCompleteMissionListState extends State<MyCompleteMissionList> {
  List<Map<String, dynamic>> completedMissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedMissions();
  }

  Future<void> fetchCompletedMissions() async {
    try {
      final response = await SessionTokenManager.get(
        'http://13.125.65.151:3000/nodetest/api/missions/missions/completed',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> missions = responseData['missions'];

        final sorted = missions
            .map((mission) => Map<String, dynamic>.from(mission))
            .toList()
          ..sort((a, b) {
            final da = DateTime.tryParse(a['m_deadline'] ?? '') ?? DateTime(1900);
            final db = DateTime.tryParse(b['m_deadline'] ?? '') ?? DateTime(1900);
            return db.compareTo(da);
          });

        setState(() {
          completedMissions = sorted;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Failed to load completed missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching completed missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchCompletedMissions,
      child: isLoading
          ? ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
          ),
        ],
      )
          : (completedMissions.isEmpty
          ? ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                '완료된 미션이 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          )
        ],
      )
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        children: buildMissionWidgets(completedMissions),
      )),
    );
  }

  List<Widget> buildMissionWidgets(List<Map<String, dynamic>> missions) {
    List<Widget> widgets = [];
    String? lastDateStr;

    for (var mission in missions) {
      final deadline = parseDateTime(mission['m_deadline']);
      final dateStr = deadline != null
          ? DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(deadline)
          : '날짜 없음';
      final timeStr =
      deadline != null ? DateFormat('HH:mm').format(deadline) : '시간 없음';

      final isSuccess = mission['m_status'] == '성공';
      final statusColor = isSuccess ? Colors.lightBlue.shade800 : Colors.red.shade800;
      final statusBg = isSuccess ? Colors.lightBlue.shade100 : Colors.red.shade100;

      if (lastDateStr != dateStr) {
        lastDateStr = dateStr;
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Text(
            dateStr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue.shade600,
            ),
          ),
        ));
      }

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['m_title'] ?? '미션 제목 없음',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mission['r_title'] ?? '방 제목 없음',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '마감 시간: $timeStr',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mission['m_status'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  DateTime? parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      print('Invalid date format: $dateString');
      return null;
    }
  }
}