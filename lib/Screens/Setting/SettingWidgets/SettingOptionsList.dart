import 'package:flutter/material.dart';
import 'ProfileEditScreen.dart';

/// 중단부 설정 옵션 리스트를 표시하는 위젯
/// 각 옵션 클릭 시 해당 기능 페이지로 이동하거나 콜백을 통해 처리
class SettingOptionsList extends StatelessWidget {
  /// ✅ 프로필 편집 결과를 상위 위젯으로 전달하는 콜백 (nullable)
  final Function(String name, ImageProvider image)? onProfileEdited;

  const SettingOptionsList({
    super.key,
    this.onProfileEdited, // nullable 처리
  });

  @override
  Widget build(BuildContext context) {
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
            InkWell(
              onTap: () {
                if (option == '프로필 편집') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  ).then((result) {
                    if (result != null && result is Map) {
                      final String name = result['name'];
                      final ImageProvider image = result['image'];
                      if (onProfileEdited != null) {
                        onProfileEdited!(name, image);
                      }
                    }
                  });
                } else {
                  print('$option 클릭됨 (아직 연결 안됨)');
                }
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
