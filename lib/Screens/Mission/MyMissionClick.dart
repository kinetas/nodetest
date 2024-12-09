import 'package:flutter/material.dart';
import 'MissionVerificationScreen.dart'; // MissionVerificationScreen import

class MissionClick extends StatelessWidget {
  final Map<String, dynamic> mission;

  MissionClick({required this.mission});

  @override
  Widget build(BuildContext context) {
    // 조건에 따라 버튼 활성화 여부 결정
    final bool isVoteEnabled = mission['u1_id'] == mission['u2_id'] &&
        mission['u2_id'] == mission['missionAuthenticationAuthority'];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mission['m_title'] ?? '제목 없음',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('마감 기한: ${mission['m_deadline'] ?? '알 수 없음'}'),
            SizedBox(height: 8),
            Text('미션 상태: ${mission['m_status'] ?? '알 수 없음'}'),
            SizedBox(height: 8),
            Text('미션 생성자: ${mission['u1_id'] ?? '알 수 없음'}'),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // MissionVerificationScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionVerificationScreen(
                          rId: mission['r_id'] ?? '',
                          u1Id: mission['u1_id'] ?? '',
                          u2Id: mission['u2_id'] ?? '',
                          mId: mission['m_id'] ?? '',
                          missionAuthenticationAuthority:
                          mission['missionAuthenticationAuthority'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Text('미션 인증'),
                ),
                ElevatedButton(
                  onPressed: isVoteEnabled
                      ? () {
                    // MissionVerificationScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionVerificationScreen(
                          rId: mission['r_id'] ?? '',
                          u1Id: mission['u1_id'] ?? '',
                          u2Id: mission['u2_id'] ?? '',
                          mId: mission['m_id'] ?? '',
                          missionAuthenticationAuthority: mission[
                          'missionAuthenticationAuthority'] ??
                              '',
                        ),
                      ),
                    );
                  }
                      : null, // 비활성화 상태
                  child: Text('미션 투표 올리기'),
                  style: ElevatedButton.styleFrom(
                    disabledForegroundColor: Colors.grey, // 비활성화 상태 텍스트 색상
                    disabledBackgroundColor: Colors.grey.shade300, // 비활성화 상태 배경 색상
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // 버튼 색상 변경
                  ),
                  onPressed: () {
                    print('미션 삭제 버튼 클릭');
                  },
                  child: Text('미션 삭제'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}