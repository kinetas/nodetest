import 'package:flutter/material.dart';

class ProfileCompletedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 완료된 미션이 없을 때 표시되는 텍스트
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              '완료된 미션이 없습니다.',
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // 6칸 그리드 영역 설정 (플라로이드용 공간 확보)
          GridView.builder(
            shrinkWrap: true, // 스크롤 안되게 내부에서만 그림
            physics: const NeverScrollableScrollPhysics(), // 외부 스크롤 사용
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3열
              mainAxisSpacing: 8.0, // 수직 간격
              crossAxisSpacing: 8.0, // 수평 간격
              childAspectRatio: 1.0, // 정사각형
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                // 추후 사진 또는 카드가 들어갈 자리
                child: const Center(
                  child: Icon(Icons.photo, color: Colors.grey),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
