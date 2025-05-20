/*
import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 변환을 위해 추가
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import '../../../SessionCookieManager.dart';
import 'MyMissionCard.dart';

class MyMissionList extends StatefulWidget {
  @override
  _MyMissionListState createState() => _MyMissionListState();
}

class _MyMissionListState extends State<MyMissionList> {
  List<Map<String, dynamic>> missions = []; // 모든 미션 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 관리
  String currentUserId = 'your_user_id'; // 현재 사용자 ID (필요시 업데이트)

  @override
  void initState() {
    super.initState();
    fetchMissions(); // API 호출
  }

  Future<void> fetchMissions() async {
    try {
      final response = await SessionCookieManager.get(
        'http://27.113.11.48:3000/api/missions/missions/assigned',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 모든 데이터를 가져와 저장
        final List<Map<String, dynamic>> fetchedMissions =
        (responseData['missions'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          missions = fetchedMissions.map((mission) {
            return {
              ...mission,
              'missionAuthenticationAuthority':
              mission['missionAuthenticationAuthority'] ?? "알 수 없음",
              'm_id': mission['m_id'] ?? "알 수 없음",
              'r_id': mission['r_id'] ?? "알 수 없음",
              'r_title': mission['r_title'] ?? "알 수 없음",
              'created_date': mission['created_date'] ?? "알 수 없음",
              'updated_date': mission['updated_date'] ?? "알 수 없음",
              'priority': mission['priority'] ?? "알 수 없음",
              'm_status': mission['m_status'] ?? "알 수 없음",
            };
          }).toList();
          isLoading = false;
        });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : missions.isEmpty
          ? Center(
        child: Text(
          '미션 없음',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : buildMissionList(),
    );
  }

  Widget buildMissionList() {
    final today = DateTime.now();
    final currentYear = today.year.toString();
    String previousYear = '';

    // 데드라인 기준으로 정렬
    missions.sort((a, b) {
      final dateA = parseDateTime(a['m_deadline']) ?? DateTime(1970);
      final dateB = parseDateTime(b['m_deadline']) ?? DateTime(1970);
      return dateA.compareTo(dateB);
    });

    final List<Widget> missionWidgets = [];
    String previousDate = '';

    for (var mission in missions) {
      final missionDate = parseDateTime(mission['m_deadline']);
      final formattedDate = missionDate != null
          ? DateFormat('MM/dd (E)', 'ko_KR').format(missionDate)
          : '알 수 없는 날짜';
      final missionYear = missionDate?.year.toString() ?? '';

      // 년도 헤더 추가
      if (missionYear != previousYear) {
        previousYear = missionYear;
        if (missionYear != currentYear) {
          missionWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                missionYear,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          );
        }
      }

      // 날짜 헤더 추가
      if (formattedDate != previousDate) {
        previousDate = formattedDate;
        missionWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ),
        );
      }

      // 미션 상태 확인
      final isRequestStatus = mission['m_status'] == "요청";

      missionWidgets.add(
        AbsorbPointer(
          absorbing: isRequestStatus, // 상태가 "요청"이면 클릭 비활성화
          child: Opacity(
            opacity: isRequestStatus ? 0.5 : 1.0, // 상태가 "요청"이면 반투명 처리
            child: MissionCard(
              mission: mission,
              currentUserId: currentUserId,
            ),
          ),
        ),
      );
    }

    return ListView(
      children: missionWidgets,
    );
  }

  DateTime? parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Invalid date format: $dateString, error: $e');
      return null;
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../SessionTokenManager.dart';
import 'MyMissionCard.dart';

class MyMissionList extends StatefulWidget {
  final Key? key;

  const MyMissionList({this.key}) : super(key: key);

  @override
  _MyMissionListState createState() => _MyMissionListState();
}

class _MyMissionListState extends State<MyMissionList> {
  List<Map<String, dynamic>> missions = [];
  bool isLoading = true;
  String currentUserId = 'your_user_id';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/api/missions/missions/assigned',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<Map<String, dynamic>> fetchedMissions =
        (responseData['missions'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          missions = fetchedMissions;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Failed to load missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching missions: $e');
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60), // 버튼 공간 확보
          child: _buildMissionList(),
        ),
        Positioned(
          top: 10,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text(
                  selectedDate == null
                      ? '날짜'
                      : DateFormat('MM/dd').format(selectedDate!),
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
              if (selectedDate != null)
                TextButton(
                  onPressed: _clearFilter,
                  child: Text(
                    '전체 보기',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList() {
    final filtered = selectedDate == null
        ? missions
        : missions.where((mission) {
      final deadline = parseDateTime(mission['m_deadline']);
      if (deadline == null) return false;
      return deadline.year == selectedDate!.year &&
          deadline.month == selectedDate!.month &&
          deadline.day == selectedDate!.day;
    }).toList();

    filtered.sort((a, b) {
      final dateA = parseDateTime(a['m_deadline']) ?? DateTime(1970);
      final dateB = parseDateTime(b['m_deadline']) ?? DateTime(1970);
      return dateA.compareTo(dateB);
    });

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          '미션 없음',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: filtered.map((mission) {
        final isRequestStatus = mission['m_status'] == "요청";
        return AbsorbPointer(
          absorbing: isRequestStatus,
          child: Opacity(
            opacity: isRequestStatus ? 0.5 : 1.0,
            child: MissionCard(
              mission: mission,
              currentUserId: currentUserId,
            ),
          ),
        );
      }).toList(),
    );
  }

  DateTime? parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Invalid date format: $dateString, error: $e');
      return null;
    }
  }
}