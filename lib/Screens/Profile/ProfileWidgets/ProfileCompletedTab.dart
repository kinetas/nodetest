import 'package:flutter/material.dart';

/// 완료된 미션 탭
/// - 프로필 화면의 TabBarView 첫 번째 탭에서 사용됨
/// - 추후 서버 또는 로컬 DB에서 완료된 미션 리스트 연동 예정
class ProfileCompletedTab extends StatelessWidget {
  const ProfileCompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '완료된 미션 정보를 불러오는 중입니다...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}