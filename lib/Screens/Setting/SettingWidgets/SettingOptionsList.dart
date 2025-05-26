import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../SettingWidgets/ProfileEditScreen.dart';

class SettingOptionsList extends StatefulWidget {
  final Function(String name, ImageProvider image)? onProfileEdited;

  const SettingOptionsList({super.key, this.onProfileEdited});

  @override
  State<SettingOptionsList> createState() => _SettingOptionsListState();
}

class _SettingOptionsListState extends State<SettingOptionsList> {
  bool _isPublicExpanded = false;
  bool _isSecurityExpanded = false;

  int _publicOption = 0; // 0: 공개, 1: 친구만 공개, 2: 비공개
  bool _autoLoginEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ✅ 프로필 편집
        _buildSimpleTile(
          title: '프로필 편집',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ).then((result) {
              if (result != null && result is Map<String, dynamic>) {
                final name = result['name'] ?? ''; // ✅ null 방어
                final image = result['image'];
                if (image != null && widget.onProfileEdited != null) {
                  widget.onProfileEdited!(name, image);
                }
              }
            });
          },
        ),

        /// ✅ 계정 공개 범위 설정
        _buildExpandableTile(
          title: '계정 공개 범위 설정',
          isExpanded: _isPublicExpanded,
          onTap: () => setState(() => _isPublicExpanded = !_isPublicExpanded),
          child: Column(
            children: List.generate(3, (index) {
              final labels = ['공개', '친구만 공개', '비공개'];
              return _buildRadioOption(
                label: labels[index],
                selected: _publicOption == index,
                onTap: () => setState(() => _publicOption = index),
              );
            }),
          ),
        ),

        /// ✅ 보안 설정
        _buildExpandableTile(
          title: '보안 설정',
          isExpanded: _isSecurityExpanded,
          onTap: () => setState(() => _isSecurityExpanded = !_isSecurityExpanded),
          child: Column(
            children: [
              _buildRadioOption(
                label: '자동 로그인',
                selected: _autoLoginEnabled,
                onTap: () => setState(() => _autoLoginEnabled = !_autoLoginEnabled),
              ),

              /// ✅ 비밀번호 관리 - 클릭 애니메이션만 적용
              InkWell(
                onTap: () {
                  print('비밀번호 관리 클릭됨');
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Text(
                      '비밀번호 관리',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// ✅ 기기 권한 설정
        _buildSimpleTile(
          title: '기기 권한 설정',
          onTap: () => openAppSettings(),
        ),
      ],
    );
  }

  Widget _buildSimpleTile({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTile({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: child,
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Icon(
                Icons.circle,
                size: 10,
                color: selected ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
