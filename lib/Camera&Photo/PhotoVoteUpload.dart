import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // 파일 이름 추출을 위해 추가
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

  Future<void> _uploadPhoto() async {
    setState(() {
      isUploading = true;
    });

    try {
      // 세션 쿠키 가져오기
      String? sessionCookie = await SessionCookieManager.getSessionCookie();

      // HTTP POST 요청 생성
      final uri = Uri.parse('http://54.180.54.31:3000/api/missions/missionVote');
      final request = http.MultipartRequest('POST', uri);

      // 헤더에 쿠키 추가
      if (sessionCookie != null) {
        request.headers['Cookie'] = sessionCookie;
      }

      // form-data 필드 추가
      request.fields['m_id'] = widget.mId;

      // 이미지 파일 첨부
      final file = File(widget.imagePath);
      request.files.add(
        http.MultipartFile(
          'file',
          file.openRead(),
          await file.length(),
          filename: basename(file.path), // 파일 이름 설정
        ),
      );

      // 요청 보내기
      final response = await request.send();

      // 응답 처리
      if (response.statusCode == 200) {
        setState(() {
          uploadMessage = "사진 업로드 성공!";
        });
      } else {
        setState(() {
          uploadMessage = "사진 업로드 실패 (상태 코드: ${response.statusCode})";
        });
      }
    } catch (e) {
      print("업로드 중 오류 발생: $e");
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
    _uploadPhoto(); // 위젯 초기화 시 업로드 수행
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