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
