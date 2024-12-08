import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../UserInfo/UserInfo_Id.dart'; // UserInfoId 클래스 import

class PhotoSend extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;

  PhotoSend({required this.imagePath, required this.rId, required this.u2Id});

  @override
  _PhotoSendState createState() => _PhotoSendState();
}

class _PhotoSendState extends State<PhotoSend> {
  String? _u1Id; // u1_id 저장 변수
  bool _isLoading = true; // 로딩 상태 관리
  TextEditingController _textController = TextEditingController(); // 텍스트 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 화면 초기화 시 u1_id 가져오기
  }

  Future<void> _loadUserId() async {
    try {
      UserInfoId userInfo = UserInfoId();
      String? userId = await userInfo.fetchUserId();
      if (userId == null) {
        throw Exception("유저 ID를 가져올 수 없습니다.");
      }
      setState(() {
        _u1Id = userId;
        _isLoading = false;
      });
    } catch (e) {
      print("유저 ID 가져오기 실패: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("유저 정보를 가져오는 데 실패했습니다.")),
      );
    }
  }

  Future<void> _sendPhoto(BuildContext context) async {
    if (_u1Id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유저 ID를 불러오는 중입니다.')),
      );
      return;
    }

    String message = _textController.text.trim(); // 메시지 가져오기
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지를 입력하세요.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://your-server-url/photosend'),
      );
      request.fields['r_id'] = widget.rId;
      request.fields['u2_id'] = widget.u2Id;
      request.fields['u1_id'] = _u1Id!; // u1_id 추가
      request.fields['message'] = message; // 메시지 추가
      request.files.add(await http.MultipartFile.fromPath('photo', widget.imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('사진 전송 성공');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 전송 성공')),
        );
        _executeRequestAction(); // 요청하기 클래스 실행
        Navigator.pop(context); // 성공 후 이전 화면으로 돌아가기
      } else {
        print('사진 전송 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 전송 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('사진 전송 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 전송 중 오류가 발생했습니다.')),
      );
    }
  }

  void _executeRequestAction() {
    RequestAction().execute(); // 요청하기 작업 실행
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("사진 전송"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("사진 전송"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이만큼 패딩
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Column 크기를 자식 크기에 맞게 줄임
              children: [
                SizedBox(
                  width: 300, // 이미지 너비
                  height: 300, // 이미지 높이
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain, // 이미지를 컨테이너 안에 맞춤
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _textController,
                    maxLength: 30, // 최대 30자 제한
                    decoration: InputDecoration(
                      labelText: "메시지 입력",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _sendPhoto(context),
                  child: Text("인증하기"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RequestAction {
  void execute() {
    print("요청하기 작업 실행");
    // 추가 작업 구현
  }
}