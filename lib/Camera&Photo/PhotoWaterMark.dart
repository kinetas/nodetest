import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'PhotoSend.dart';

class PhotoWaterMark extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;

  PhotoWaterMark({
    required this.imagePath,
    required this.rId,
    required this.u2Id,
  });

  @override
  _PhotoWaterMarkState createState() => _PhotoWaterMarkState();
}

class _PhotoWaterMarkState extends State<PhotoWaterMark> {
  File? _imageFile;
  TextEditingController _textController = TextEditingController(); // 메시지 입력을 위한 컨트롤러
  String _message = ''; // 하단에 표시할 메시지

  @override
  void initState() {
    super.initState();
    _applyPolaroidEffect(); // 폴라로이드 효과를 적용
  }

  Future<void> _applyPolaroidEffect() async {
    try {
      // 원본 이미지 로드
      final ui.Image image = await decodeImageFromList(
        File(widget.imagePath).readAsBytesSync(),
      );

      // 폴라로이드 캔버스 생성
      final double padding = 20.0;
      final double bottomSpace = 150.0; // 바닥 공간을 늘려서 150으로 설정
      final double canvasWidth = image.width.toDouble() + padding * 2;
      final double canvasHeight = image.height.toDouble() + padding + bottomSpace;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 배경 그리기
      final Paint paint = Paint()
        ..color = Colors.white;
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
      // 흰색 텍스트를 약간 오프셋을 주어 테두리 효과
      whiteTextPainter.paint(canvas, textOffset.translate(3.0, 3.0)); // 오프셋을 더 크게 주어 테두리 강조

      // 검은색 텍스트 그리기
      textPainter.paint(canvas, textOffset);

      // 사용자 메시지 추가 (하단에 표시)
      if (_message.isNotEmpty) {
        final messageTextPainter = TextPainter(
          text: TextSpan(
            text: _message, // 사용자 입력 메시지
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        messageTextPainter.layout(
          minWidth: 0,
          maxWidth: canvasWidth - padding * 2,
        );
        final messageTextOffset = Offset(
          padding, // 왼쪽 여백
          image.height.toDouble() + padding + 20.0, // 폴라로이드 아래 여백
        );

        // 텍스트의 흰색 테두리 그리기 (두꺼운 테두리)
        final whiteMessageTextPainter = TextPainter(
          text: TextSpan(text: _message, style: TextStyle(color: Colors.white, fontSize: 20)),
          textDirection: ui.TextDirection.ltr,
        );
        whiteMessageTextPainter.layout();
        whiteMessageTextPainter.paint(canvas, messageTextOffset.translate(3.0, 3.0)); // 테두리 강조

        // 검은색 텍스트 그리기
        messageTextPainter.paint(canvas, messageTextOffset);
      }

      // 이미지 저장
      final picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        canvasWidth.toInt(),
        canvasHeight.toInt(),
      );

      final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final outputFile = File('${tempDir.path}/polaroid_image.png');
      await outputFile.writeAsBytes(buffer);

      setState(() {
        _imageFile = outputFile;
      });
    } catch (e) {
      print("폴라로이드 효과 적용 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("폴라로이드 효과 적용 중 오류가 발생했습니다.")),
      );
    }
  }

  // 확대된 이미지 화면
  void _showImageInFullScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InteractiveViewer(
            child: Image.file(_imageFile!),
          ),
        );
      },
    );
  }

  // "다음" 버튼 눌렀을 때 PhotoSend로 넘어가기
  void _navigateToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoSend(
          imagePath: _imageFile!.path,
          rId: widget.rId,
          u2Id: widget.u2Id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("폴라로이드 효과"),
      ),
      body: Center(
        child: _imageFile == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _showImageInFullScreen, // 이미지 클릭 시 확대
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 80% of the screen width
                height: MediaQuery.of(context).size.height * 0.5, // 50% of the screen height
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.contain, // Ensures the image is scaled to fit
                ),
              ),
            ),
            SizedBox(height: 20),
            // 메시지 입력 필드 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: "메시지 입력",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _message = _textController.text.trim(); // 입력된 메시지 업데이트
                  _applyPolaroidEffect(); // 폴라로이드 효과와 메시지 추가
                });
              },
              child: Text("확인"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToNextScreen, // "다음" 버튼 눌렀을 때 PhotoSend 화면으로 이동
              child: Text("다음"),
            ),
          ],
        ),
      ),
    );
  }
}