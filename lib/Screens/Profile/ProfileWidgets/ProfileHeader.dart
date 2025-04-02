import 'package:flutter/material.dart';

/// 프로필 상단 영역 위젯
/// - 프로필 사진과 사용자 이름을 표시함
/// - 세팅 영역에서 사진과 이름 수정 가능하게 변경
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        /// 프로필 사진
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 10),

        /// 사용자 이름
        Text(
          '사용자 이름',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }
}
