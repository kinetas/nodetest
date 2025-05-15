import 'package:flutter/material.dart';

class ProfileInProgressTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // 진행 중인 미션이 없을 때 표시되는 텍스트
          Text(
            '진행 중인 미션이 없습니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
