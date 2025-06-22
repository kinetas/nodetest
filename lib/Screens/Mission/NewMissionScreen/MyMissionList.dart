import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'MissionClick.dart';
import '../../../SessionTokenManager.dart';

class MyMissionList extends StatefulWidget {
  final Key? key;
  final DateTime? selectedDate;
  final bool hideDateHeader;
  final bool showMissionCount;

  const MyMissionList({
    this.key,
    this.selectedDate,
    this.hideDateHeader = false,
    this.showMissionCount = true,
  }) : super(key: key);

  @override
  _MyMissionListState createState() => _MyMissionListState();
}

class _MyMissionListState extends State<MyMissionList> {
  List<Map<String, dynamic>> missions = [];
  bool isLoading = true;
  int? assignedCount;

  @override
  void initState() {
    super.initState();
    fetchMissions();
    fetchAssignedMissionCount();
  }

  Future<void> fetchAssignedMissionCount() async {
    try {
      final response = await SessionTokenManager.get(
        'http://13.125.65.151:3000/nodetest/dashboard/missions/getAssignedMissionNumber',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          assignedCount = data['assignedMissionCount'] ?? 0;
        });
      } else {
        print('⚠️ 미션 수 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 미션 수 가져오기 오류: $e');
    }
  }

  Future<void> fetchMissions() async {
    setState(() => isLoading = true);
    try {
      final response = await SessionTokenManager.get(
        'http://13.125.65.151:3000/nodetest/api/missions/missions/assigned',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic rawMissions = responseData['missions'];

        final List<Map<String, dynamic>> fetchedMissions = rawMissions is List
            ? rawMissions.map((item) => Map<String, dynamic>.from(item)).toList()
            : (rawMissions as Map<String, dynamic>)
            .values
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          missions = fetchedMissions
              .where((m) => m['m_status'] == '진행중')
              .toList();
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

  @override
  Widget build(BuildContext context) {
    final filtered = widget.selectedDate == null
        ? missions
        : missions.where((mission) {
      final deadline = parseDateTime(mission['m_deadline'])?.toLocal();
      if (deadline == null) return false;
      return deadline.year == widget.selectedDate!.year &&
          deadline.month == widget.selectedDate!.month &&
          deadline.day == widget.selectedDate!.day;
    }).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await fetchMissions();
          await fetchAssignedMissionCount();
        },
        child: isLoading
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
            ),
          ],
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (widget.showMissionCount && (assignedCount ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      '🔔 현재 진행 중인 미션: $assignedCount개',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                if (filtered.isEmpty)
                  SizedBox(
                    height: constraints.maxHeight * 0.6,
                    child: const Center(
                      child: Text(
                        '오늘의 미션이 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...buildMissionWidgets(filtered),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildMissionWidgets(List<Map<String, dynamic>> missions) {
    missions.sort((a, b) {
      final da = parseDateTime(a['m_deadline']) ?? DateTime(2100);
      final db = parseDateTime(b['m_deadline']) ?? DateTime(2100);
      return da.compareTo(db);
    });

    List<Widget> missionWidgets = [];
    String? previousDateKey;

    for (var mission in missions) {
      final deadline = parseDateTime(mission['m_deadline']);
      final formattedDate = deadline != null
          ? DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(deadline)
          : '날짜 없음';
      final formattedTime =
      deadline != null ? DateFormat('HH:mm').format(deadline) : '시간 없음';

      String? timeLeftMessage;
      if (deadline != null) {
        final now = DateTime.now();
        final difference = deadline.difference(now);
        if (difference.inMinutes <= 60 && difference.inMinutes > 50) {
          timeLeftMessage = '⏰ 마감까지 1시간 전';
        } else if (difference.inMinutes <= 30 && difference.inMinutes > 25) {
          timeLeftMessage = '⏰ 마감까지 30분 전';
        } else if (difference.inMinutes <= 10 && difference.inMinutes > 5) {
          timeLeftMessage = '⏰ 마감까지 10분 전';
        } else if (difference.inMinutes <= 5 && difference.inMinutes > 0) {
          timeLeftMessage = '⏰ 마감까지 5분 전';
        }
      }

      if (!widget.hideDateHeader && formattedDate != previousDateKey) {
        previousDateKey = formattedDate;
        missionWidgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue.shade600,
            ),
          ),
        ));
      }

      final isRequestStatus = mission['m_status'] == "요청";

      missionWidgets.add(
        AbsorbPointer(
          absorbing: isRequestStatus,
          child: Opacity(
            opacity: isRequestStatus ? 0.5 : 1.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => MissionClick(
                    mission: mission,
                    onAuthenticate: () {},
                  ),
                );
              },
              child: Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mission['m_title'] ?? '미션 제목 없음',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (timeLeftMessage != null)
                            Text(
                              timeLeftMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (mission['u1_id'] == mission['u2_id'] &&
                            mission['u2_id'] == mission['missionAuthenticationAuthority'])
                            ? '인증 받을 곳: 미션 투표'
                            : mission['missionAuthenticationAuthority'] != null
                            ? '인증 받을 사람: ${mission['missionAuthenticationAuthority']}'
                            : '인증 받을 곳: 미션 투표',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '마감 시간: $formattedTime',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mission['m_status'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.lightBlue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    missionWidgets.add(SizedBox(height: MediaQuery.of(context).padding.bottom + 100));
    return missionWidgets;
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