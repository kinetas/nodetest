import 'package:flutter/material.dart';

/// 진행중인 미션 탭
/// - 프로필 화면의 TabBarView 두 번째 탭에서 사용됨
/// - 실제 진행중인 미션을 연결할 예정 (현재는 placeholder)
class ProfileInProgressTab extends StatelessWidget {
  const ProfileInProgressTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '진행중인 미션 정보를 불러오는 중입니다...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
