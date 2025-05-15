/*
import 'package:flutter/material.dart';

/// 프로필 상단 영역 위젯
/// - 외부에서 사용자 이름과 프로필 이미지를 전달받아 표시함
class ProfileHeader extends StatelessWidget {
  final String userName;
  final ImageProvider profileImage;

  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 프로필 사진
        CircleAvatar(
          radius: 40,
          backgroundImage: profileImage,
        ),

        const SizedBox(height: 10),

        /// 사용자 이름
        Text(
          userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
*/

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;

  const ProfileHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.lightBlue;

    return Column(
      children: [
        // 미션 통계 상단 정보
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 통계 항목: 완료/실패 미션 수
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('완료한 미션 00', style: TextStyle(color: Colors.lightBlue)),
                  SizedBox(height: 4),
                  Text('실패한 미션 00', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
              // 오른쪽 통계 항목: 생성/진행중 미션 수
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('생성한 미션 00', style: TextStyle(color: Colors.black87)),
                  SizedBox(height: 4),
                  Text('진행중 미션 00', style: TextStyle(color: Colors.black87)),
                ],
              ),
            ],
          ),
        ),

        // 프로필 이미지 및 유저 이름
        Column(
          children: [
            // 원형 프로필 이미지 아이콘
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 12),

            // 사용자 이름
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
