import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../SessionTokenManager.dart';

class ProfileCompletedTab extends StatefulWidget {
  @override
  _ProfileCompletedTabState createState() => _ProfileCompletedTabState();
}

class _ProfileCompletedTabState extends State<ProfileCompletedTab> {
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

        setState(() {
          completedMissions = missions.map<Map<String, dynamic>>((mission) {
            return {
              'm_id': mission['m_id'] ?? '',
              'm_title': mission['m_title'] ?? 'No Title',
              'imgUrl': mission['imgUrl'],
              'm_status': mission['m_status'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load completed missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching completed missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey[300]!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (completedMissions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Center(
          child: Text(
            '완료된 미션이 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final gridMissions = List<Map<String, dynamic>>.from(completedMissions);
    while (gridMissions.length < 6) {
      gridMissions.add({});
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final mission = gridMissions[index];
          final hasData = mission.isNotEmpty;
          final imgUrl = mission['imgUrl'];
          final mTitle = (mission['m_title'] ?? '').toString();
          final mStatus = mission['m_status'];

          // 상태 없으면 실패(빨간 점)
          final isSuccess = mStatus == '성공';
          final isFail = mStatus == '실패' || mStatus == null || mStatus == '';

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: hasData
                ? Stack(
              children: [
                // 1. 이미지 or 첫글자
                Positioned.fill(
                  child: imgUrl != null && imgUrl.toString().isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildTitleAvatar(mTitle),
                    ),
                  )
                      : _buildTitleAvatar(mTitle),
                ),
                // 2. 성공/실패 점(우상단)
                if (isSuccess || isFail)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.blue : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // 3. 제목(하단, 배경X, 텍스트만)
                if (mTitle.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: Text(
                      mTitle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            )
                : _buildEmptySlot(),
          );
        },
      ),
    );
  }

  // 이미지 없을 때: 첫글자(파란색, 위로 살짝 올림)
  Widget _buildTitleAvatar(String title) {
    String displayChar = '';
    if (title.trim().isNotEmpty) {
      displayChar = title.trim().characters.first;
    }

    return Align(
      alignment: const Alignment(0, -0.3), // 중앙보다 위쪽으로 배치
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          displayChar,
          style: const TextStyle(
            color: Colors.blue, // 파란계열!
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 빈 칸
  Widget _buildEmptySlot() {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
