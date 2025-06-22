import 'package:flutter/material.dart';
import '../../NewCommunity/CreateRecruit.dart'; // ✅ 경로 확인

class CreateMissionWithOther extends StatelessWidget {
  final String? initialTitle;     // ✅ AI 제목
  final String? initialCategory;  // ✅ AI 카테고리

  const CreateMissionWithOther({
    super.key,
    this.initialTitle,
    this.initialCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티에서 미션 생성'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '이 미션은 커뮤니티에 공개되어\n다른 사용자들과 함께 할 수 있어요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRecruit(
                      initialTitle: initialTitle,
                      initialCategory: initialCategory, // ✅ 전달
                    ),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('미션 생성이 완료되었습니다!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '미션 만들기 시작',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}