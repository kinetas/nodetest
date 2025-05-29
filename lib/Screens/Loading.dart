import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String message;      // 표시할 텍스트(옵션)

  const Loading({Key? key, this.message = "로딩 중..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용만큼만 세로 차지
        children: [
          // 버퍼링(로딩)용 이미지
          Image.asset(
            'assets/Loading.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          // 로딩 메시지
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
