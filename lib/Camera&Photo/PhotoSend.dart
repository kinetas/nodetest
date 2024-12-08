import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; // 파일 경로에서 확장자 추출
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../SessionCookieManager.dart'; // 세션 쿠키 관리 클래스 import

class PhotoSend extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;

  PhotoSend({required this.imagePath, required this.rId, required this.u2Id});

  @override
  _PhotoSendState createState() => _PhotoSendState();
}

class _PhotoSendState extends State<PhotoSend> {
  late IO.Socket socket;
  String? _u1Id; // 유저 ID
  bool _isLoading = true; // 로딩 상태 관리
  TextEditingController _textController = TextEditingController(); // 메시지 입력 필드

  @override
  void initState() {
    super.initState();
    _initializeSocket(); // 소켓 초기화
    _loadUserId(); // 유저 ID 로드
  }

  @override
  void dispose() {
    socket.disconnect(); // 소켓 연결 해제
    socket.dispose();
    _textController.dispose(); // 입력 필드 해제
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    print("Initializing socket...");
    socket = IO.io(
      'http://54.180.54.31:3001',
      IO.OptionBuilder()
          .setTransports(['websocket']) // WebSocket 사용
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('joinRoom', {
        'r_id': widget.rId,
        'u1_id': _u1Id,
        'u2_id': widget.u2Id,
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      socket.connect(); // 연결 끊어질 경우 재연결
    });

    socket.connect(); // 소켓 연결 시작
  }

  Future<void> _loadUserId() async {
    print("Loading user ID...");
    try {
      final response = await SessionCookieManager.get('http://54.180.54.31:3000/api/user-info/user-id');
      if (response.statusCode == 200) {
        // JSON 객체에서 ID 추출
        final userId = response.body.contains('u_id')
            ? response.body.split(':')[1].replaceAll(RegExp(r'[{}"]'), '').trim()
            : response.body.trim();

        setState(() {
          _u1Id = userId; // 유저 ID 설정
          _isLoading = false; // 로딩 상태 해제
        });
        print("User ID loaded: $_u1Id");
      } else {
        throw Exception('Failed to fetch user ID.');
      }
    } catch (e) {
      print('Error loading user ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user ID.')),
      );
      setState(() {
        _isLoading = false; // 로딩 상태 해제
      });
    }
  }

  void _sendMessage() {
    final messageContent = _textController.text.trim();
    if (messageContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지를 입력하세요.')),
      );
      return;
    }

    try {
      // 이미지 파일 읽기
      final imageBytes = File(widget.imagePath).readAsBytesSync();
      print("Image file read successfully.");

      // 이미지 타입 추출
      final imageType = path.extension(widget.imagePath).replaceFirst('.', '');
      print("Image type: $imageType");

      final messageData = {
        'r_id': widget.rId,
        'u1_id': _u1Id,
        'u2_id': widget.u2Id,
        'message_contents': messageContent,
        'send_date': DateTime.now().toIso8601String(),
        'image': imageBytes, // 이미지 데이터를 바이너리로 전송
        'image_type': imageType, // 이미지 타입 추가
      };

      print('Sending message: $messageData');
      socket.emit('sendMessage', messageData);

      // 서버 응답 확인
      socket.on('messageSent', (data) {
        print('Message sent successfully: $data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent successfully.')),
        );

        // 모든 화면 닫기 (CameraMain.dart까지 닫기)
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Sending Photo"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Send Photo"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _textController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: "Enter your message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text("Send"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}