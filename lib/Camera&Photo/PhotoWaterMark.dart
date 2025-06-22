import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data'; // ByteData 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'PhotoSend.dart';
import 'PhotoVoteUpload.dart';

class PhotoWaterMark extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u1Id;
  final String u2Id;
  final String mId;
  final String missionAuthenticationAuthority;
  final String? voteM; // 선택적 파라미터 (null 가능)

  PhotoWaterMark({
    required this.imagePath,
    required this.rId,
    required this.u1Id,
    required this.u2Id,
    required this.mId,
    required this.missionAuthenticationAuthority,
    this.voteM,
  });

  @override
  _PhotoWaterMarkState createState() => _PhotoWaterMarkState();
}

class _PhotoWaterMarkState extends State<PhotoWaterMark> {
  @override
  void initState() {
    super.initState();

    // 📸 디버깅 로그 — 모든 파라미터 출력
    print("📸 [PhotoWaterMark 시작]");
    print("📷 imagePath: ${widget.imagePath}");
    print("🆔 rId: ${widget.rId}");
    print("👤 u1Id: ${widget.u1Id}");
    print("👥 u2Id: ${widget.u2Id}");
    print("🎯 mId: ${widget.mId}");
    print("🔐 missionAuthenticationAuthority: ${widget.missionAuthenticationAuthority}");
    print("🗳️ voteM: ${widget.voteM}");

    _applyPolaroidEffect(widget.imagePath);
  }

  Future<void> _applyPolaroidEffect(String imagePath) async {
    try {
      print("폴라로이드 효과 생성 중 경로: $imagePath");

      // 이미지 로드
      final ui.Image image = await decodeImageFromList(
        File(imagePath).readAsBytesSync(),
      );

      // 폴라로이드 캔버스 생성
      final double padding = 20.0;
      final double bottomSpace = 150.0; // 바닥 공간을 늘려서 150으로 설정
      final double canvasWidth = image.width.toDouble() + padding * 2;
      final double canvasHeight = image.height.toDouble() + padding + bottomSpace;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 배경 그리기
      final Paint paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), paint);

      // 원본 이미지 그리기 (위로 올리기 위해 Y 좌표를 조정)
      canvas.drawImage(image, Offset(padding, padding), Paint());

      // 현재 시간 텍스트 추가
      String dateTimeText = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final textStyle = TextStyle(color: Colors.black, fontSize: 24);

      final textPainter = TextPainter(
        text: TextSpan(
          text: dateTimeText, // 시간 텍스트
          style: textStyle,
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: canvasWidth - padding * 2,
      );

      final textOffset = Offset(
        image.width.toDouble() - textPainter.width - 20.0, // 오른쪽 끝에서 약간 여백
        image.height.toDouble() - textPainter.height - 20.0, // 아래쪽에서 여백
      );

      // 텍스트의 흰색 테두리 그리기 (두꺼운 테두리)
      final whiteTextStyle = TextStyle(color: Colors.white, fontSize: 24);
      final whiteTextPainter = TextPainter(
        text: TextSpan(text: dateTimeText, style: whiteTextStyle),
        textDirection: ui.TextDirection.ltr,
      );
      whiteTextPainter.layout();
      whiteTextPainter.paint(canvas, textOffset.translate(3.0, 3.0)); // 테두리 효과 강조

      // 검은색 텍스트 그리기
      textPainter.paint(canvas, textOffset);

      // 이미지 저장
      final picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );

      final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // 이후 생성된 파일 경로를 생성
      final tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final outputFile = File('${tempDir.path}/polaroid_image_$timestamp.png');
      await outputFile.writeAsBytes(buffer);

      print("폴라로이드 효과 생성 완료, 경로: ${outputFile.path}");

      // VoteM 값에 따라 적절한 화면으로 이동
      if (widget.voteM == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoSend(
              imagePath: outputFile.path, // 최종 이미지 경로
              rId: widget.rId,           // rId 전달
              u2Id: widget.u2Id,         // u2Id 전달
              mId: widget.mId,
              missionAuthenticationAuthority: widget.missionAuthenticationAuthority, // 권한 전달
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoVoteUpload(
              imagePath: outputFile.path, // 최종 이미지 경로
              rId: widget.rId,           // rId 전달
              u2Id: widget.u2Id,         // u2Id 전달
              mId: widget.mId,
            ),
          ),
        );
      }
    } catch (e) {
      print("폴라로이드 효과 적용 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("워터마크 생성 실패. 다시 시도해주세요.")),
      );
      Navigator.pop(context); // 이전 화면으로 돌아가기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("워터마크 찍는 중...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}