import 'package:flutter/material.dart';
import 'MissionVerificationScreen.dart';

class MissionClick extends StatelessWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onAuthenticate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MissionClick({
    Key? key,
    required this.mission,
    required this.onAuthenticate,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = mission['r_title'] ?? mission['m_title'] ?? '미션 이름 없음';
    final String status = mission['m_status'] ?? '상태 없음';
    final String deadlineDate =
        mission['m_deadline']?.toString().split('T').first ?? '날짜 없음';
    final String deadlineTime = mission['m_deadline'] != null
        ? TimeOfDay.fromDateTime(DateTime.parse(mission['m_deadline']).toLocal()).format(context)
        : '시간 없음';

    final bool isVoteMode = mission['u1_id'] == mission['u2_id'] &&
        mission['u2_id'] == mission['missionAuthenticationAuthority'];

    final String authorityLabel =
    isVoteMode
        ? '미션 투표'
        : (mission['missionAuthenticationAuthority'] != null
        ? mission['missionAuthenticationAuthority']
        : '미션 투표');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow('상태', status),
            _infoRow('마감일', deadlineDate),
            _infoRow('마감 시간', deadlineTime),
            _infoRow(
              '인증 받을 곳',
              authorityLabel == '미션 투표'
                  ? '미션 투표'
                  : '$authorityLabel',
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  if (isVoteMode)
                    ElevatedButton(
                      onPressed: () {
                        print('📤 [미션 투표 모드]');
                        print('rId: ${mission['r_id']}');
                        print('u1Id: ${mission['u1_id']}');
                        print('u2Id: ${mission['u2_id']}');
                        print('mId: ${mission['m_id']}');
                        print('auth: ${mission['missionAuthenticationAuthority']}');

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
                              voteM: "check",
                            ),
                          ),
                        );
                      },
                      child: const Text('미션 투표 올리기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 다이얼로그 닫기

                        print('📤 [인증 모드]');
                        print('rId: ${mission['r_id']}');
                        print('u1Id: ${mission['u1_id']}');
                        print('u2Id: ${mission['u2_id']}');
                        print('mId: ${mission['m_id']}');
                        print('auth: ${mission['missionAuthenticationAuthority']}');

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
                              voteM: null,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('미션 인증하기'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}