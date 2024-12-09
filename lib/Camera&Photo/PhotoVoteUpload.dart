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
  String uploadMessage = "사진 업로드 중...";

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

  @override
  void initState() {
    super.initState();
    _uploadPhotoWithDio(); // 위젯 초기화 시 업로드 수행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("미션 투표 업로드"),
      ),
      body: Center(
        child: isUploading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(uploadMessage),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(uploadMessage, style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}