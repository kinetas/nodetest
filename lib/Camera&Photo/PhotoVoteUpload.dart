import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../SessionCookieManager.dart';

class PhotoVoteUpload extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;
  final String mId;

  PhotoVoteUpload({
    required this.imagePath,
    required this.rId,
    required this.u2Id,
    required this.mId,
  });

  @override
  _PhotoVoteUploadState createState() => _PhotoVoteUploadState();
}

class _PhotoVoteUploadState extends State<PhotoVoteUpload> {
  bool isUploading = false; // 업로드 상태 관리
  String uploadMessage = "";

  Future<void> _uploadPhotoWithDio() async {
    setState(() {
      isUploading = true;
    });

    final dio = Dio();

    // API 엔드포인트 URL
    final url = 'http://54.180.54.31:3000/api/missions/missionVote';

    try {
      // 세션 쿠키 가져오기
      String? sessionCookie = await SessionCookieManager.getSessionCookie();

      // 이미지 파일 체크
      final file = File(widget.imagePath);
      if (!file.existsSync()) {
        setState(() {
          uploadMessage = "파일이 존재하지 않습니다.";
        });
        return;
      }

      // form-data 데이터 생성
      FormData formData = FormData.fromMap({
        'm_id': widget.mId, // 미션 ID
        'c_image': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last, // 파일 이름 설정
        ),
      });

      // 요청 전송
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            if (sessionCookie != null) 'Cookie': sessionCookie,
          },
        ),
      );

      // 응답 처리
      if (response.statusCode == 200) {
        setState(() {
          uploadMessage = "사진 업로드 성공!";
        });
        _showUploadSuccessDialog();
      } else {
        setState(() {
          uploadMessage = "업로드 실패: ${response.statusCode}, 본문: ${response.data}";
        });
      }
    } catch (error) {
      print('업로드 중 오류 발생: $error');
      setState(() {
        uploadMessage = "업로드 중 오류 발생. 다시 시도해주세요.";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("투표 업로드 완료!"),
          content: Text("투표 업로드가 성공적으로 완료되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 이전 화면으로 돌아가기
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // 클릭 시 다이얼로그 닫기
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: InteractiveViewer(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("미션 투표 업로드"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지 미리 보기 (클릭 시 확대)
            Expanded(
              child: GestureDetector(
                onTap: _showImagePreview, // 이미지 클릭 시 확대 미리 보기
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 16),
            // 업로드 버튼
            ElevatedButton(
              onPressed: isUploading
                  ? null // 업로드 중일 경우 버튼 비활성화
                  : _uploadPhotoWithDio,
              child: isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("투표 업로드"),
            ),
            if (uploadMessage.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(uploadMessage, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}