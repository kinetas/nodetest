// lib/Screens/Setting/SettingWidgets/SettingOptionsList.dart

import 'package:flutter/material.dart';

/// 중단부 설정 옵션 리스트를 표시하는 위젯
/// 현재는 콜백 없이 UI만 구현되어 있으며,
/// 추후 각 옵션 클릭 시 페이지 이동 또는 팝업 연결 가능
class SettingOptionsList extends StatelessWidget {
  const SettingOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    // 설정 항목들을 리스트로 정의
    final List<String> options = [
      '프로필 편집',
      '계정 공개 범위 설정',
      '친구 관리',
      '기기 권한 설정',
      '보안 설정',
    ];

    return Column(
      children: options.map((option) {
        return Column(
          children: [
            // 각 항목마다 클릭 가능한 InkWell 영역 생성
            InkWell(
              onTap: () {
                // TODO: 각 항목 클릭 시 실행될 동작 연결 예정
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
            // 항목 구분용 회색 선
            const Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
          ],
        );
      }).toList(),
    );
  }
}
