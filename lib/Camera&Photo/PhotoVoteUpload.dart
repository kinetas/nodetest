import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 수정

class PhotoVoteUpload extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;
  final String mId;

  const PhotoVoteUpload({
    required this.imagePath,
    required this.rId,
    required this.u2Id,
    required this.mId,
  });

  @override
  _PhotoVoteUploadState createState() => _PhotoVoteUploadState();
}

class _PhotoVoteUploadState extends State<PhotoVoteUpload> {
  bool isUploading = false;
  String uploadMessage = "";

  Future<void> _uploadPhotoWithDio() async {
    setState(() => isUploading = true);

    final dio = Dio();
    final url = 'http://13.125.65.151:3000/nodetest/api/missions/missionVote';

    try {
      final token = await SessionTokenManager.getToken();

      final file = File(widget.imagePath);
      if (!file.existsSync()) {
        setState(() => uploadMessage = "파일이 존재하지 않습니다.");
        return;
      }

      FormData formData = FormData.fromMap({
        'm_id': widget.mId,
        'c_image': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() => uploadMessage = "사진 업로드 성공!");
        _showUploadSuccessDialog();
      } else {
        setState(() => uploadMessage = "업로드 실패: ${response.statusCode}, 본문: ${response.data}");
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
      setState(() => uploadMessage = "업로드 중 오류 발생. 다시 시도해주세요.");
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("투표 업로드 완료!", style: TextStyle(color: Colors.lightBlue)),
        content: Text("투표 업로드가 성공적으로 완료되었습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: InteractiveViewer(
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("미션 투표 업로드", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue[100]!, Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _showImagePreview,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isUploading ? null : _uploadPhotoWithDio,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploading ? Colors.grey : Colors.lightBlue[400],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("투표 업로드", style: TextStyle(fontSize: 18)),
            ),
            if (uploadMessage.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(uploadMessage, style: TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}