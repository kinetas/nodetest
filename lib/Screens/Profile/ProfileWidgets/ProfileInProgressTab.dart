import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../SessionTokenManager.dart';

class ProfileInProgressTab extends StatefulWidget {
  @override
  _ProfileInProgressTabState createState() => _ProfileInProgressTabState();
}

class _ProfileInProgressTabState extends State<ProfileInProgressTab> {
  List<Map<String, dynamic>> progressingMissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgressingMissions();
  }

  Future<void> fetchProgressingMissions() async {
    try {
      final response = await SessionTokenManager.get(
        'http://27.113.11.48:3000/nodetest/api/missions/missions/assigned',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final dynamic rawMissions = responseData['missions'];
        final List<Map<String, dynamic>> fetchedMissions =
        rawMissions is List
            ? rawMissions.map((item) => Map<String, dynamic>.from(item)).toList()
            : (rawMissions as Map<String, dynamic>)
            .values
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        // 진행중 미션만 추출 (m_status가 '진행중')
        final List<Map<String, dynamic>> progressing = fetchedMissions
            .where((mission) => mission['m_status'] == '진행중')
            .toList();

        setState(() {
          progressingMissions = progressing;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load progressing missions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching progressing missions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey[300]!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (progressingMissions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Center(
          child: Text(
            '진행 중인 미션이 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final gridMissions = List<Map<String, dynamic>>.from(progressingMissions);
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
          final mDeadline = mission['m_deadline'];

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: hasData
                ? Stack(
              children: [
                // 이미지 or 첫글자
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
                // 제목(하단, 배경X, 텍스트만)
                if (mTitle.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
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
                // 마감일(제목 아래, 조금 더 작은 글씨)
                if (mDeadline != null && mDeadline.toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Text(
                      _formatDeadline(mDeadline),
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
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
      alignment: const Alignment(0, -0.3),
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
            color: Colors.blue,
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

  // 마감일 포맷
  String _formatDeadline(dynamic deadline) {
    try {
      final dt = DateTime.parse(deadline.toString());
      return DateFormat('~ MM/dd HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }
}
