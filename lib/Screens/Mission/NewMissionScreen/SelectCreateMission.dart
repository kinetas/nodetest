import 'package:flutter/material.dart';
import 'CreateMyMission.dart';
import 'CreateMissionWithFriend.dart';
import 'CreateMissionWithOther.dart';

class SelectCreateMission extends StatefulWidget {
  final String? initialTitle;
  final String? initialCategory;

  const SelectCreateMission({
    Key? key,
    this.initialTitle,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<SelectCreateMission> createState() => _SelectCreateMissionState();
}

class _SelectCreateMissionState extends State<SelectCreateMission> {
  bool showAloneOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('미션 생성'),
        backgroundColor: Colors.lightBlue, // ✅ 파란색 포인트
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '어떤 방식으로 미션을 시작할까요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '혼자 하거나 친구와, 또는 커뮤니티와 함께 할 수 있어요.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            _buildMainButton(
              icon: Icons.person,
              text: '혼자 하기',
              onTap: () {
                setState(() => showAloneOptions = !showAloneOptions);
              },
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showAloneOptions
                  ? Column(
                key: const ValueKey('aloneOptions'),
                children: [
                  const SizedBox(height: 12),
                  _buildSubButton(
                    icon: Icons.verified_user,
                    text: '친구에게 인증 받기',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMyMission(
                            authByFriend: true,
                            initialTitle: widget.initialTitle,
                            initialCategory: widget.initialCategory,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSubButton(
                    icon: Icons.public,
                    text: '커뮤니티에게 인증 받기',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMyMission(
                            authByFriend: false,
                            initialTitle: widget.initialTitle,
                            initialCategory: widget.initialCategory,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              )
                  : const SizedBox(height: 20),
            ),

            _buildMainButton(
              icon: Icons.group,
              text: '친구랑 하기',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateMissionWithFriend(
                      initialTitle: widget.initialTitle,
                      initialCategory: widget.initialCategory,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            _buildMainButton(
              icon: Icons.forum,
              text: '커뮤니티에서 생성하기',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateMissionWithOther(
                      initialTitle: widget.initialTitle,
                      initialCategory: widget.initialCategory,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue, // ✅ 파란색 메인 버튼
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.lightBlue),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.lightBlue, // ✅ 파란색 글씨
          elevation: 1,
          side: const BorderSide(color: Colors.lightBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}