import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../SessionTokenManager.dart'; // ✅ Token 기반으로 수정
import 'dart:convert';
import '../Screens/Mission/MissionCertification_screen.dart';

class PhotoSend extends StatefulWidget {
  final String imagePath;
  final String rId;
  final String u2Id;
  final String mId;
  final String missionAuthenticationAuthority;

  const PhotoSend({
    required this.imagePath,
    required this.rId,
    required this.u2Id,
    required this.mId,
    required this.missionAuthenticationAuthority,
  });

  @override
  _PhotoSendState createState() => _PhotoSendState();
}

class _PhotoSendState extends State<PhotoSend> {
  late IO.Socket socket;
  String? _u1Id;
  bool _isLoading = true;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _disconnectSocket();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    socket = IO.io(
      'http://54.180.54.31:3001',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      socket.emit('joinRoom', {
        'r_id': widget.rId,
        'u1_id': _u1Id,
        'u2_id': widget.missionAuthenticationAuthority,
      });
    });

    socket.connect();
  }

  Future<void> _disconnectSocket() async {
    if (socket.connected) {
      socket.emit('leaveRoom', {
        'r_id': widget.rId,
        'u1_id': _u1Id,
      });
      socket.disconnect();
    }
  }

  Future<void> _loadUserId() async {
    try {
      final token = await SessionTokenManager.getToken();
      final response = await HttpClient()
          .getUrl(Uri.parse('http://54.180.54.31:3000/api/user-info/user-id'))
          .then((req) {
        req.headers.set('Authorization', 'Bearer $token');
        return req.close();
      });

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final userId = json.decode(responseBody)['u_id'];
        setState(() {
          _u1Id = userId;
          _isLoading = false;
        });
        _initializeSocket(); // ✅ 소켓 연결은 UserID 받은 후에 수행
      } else {
        throw Exception('Failed to fetch user ID.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유저 정보 조회 실패')),
      );
      setState(() {
        _isLoading = false;
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
      final imageBytes = File(widget.imagePath).readAsBytesSync();
      final imageType = path.extension(widget.imagePath).replaceFirst('.', '');

      final messageData = {
        'r_id': widget.rId,
        'u1_id': _u1Id,
        'u2_id': widget.missionAuthenticationAuthority,
        'message_contents': messageContent,
        'send_date': DateTime.now().toIso8601String(),
        'image': imageBytes,
        'image_type': imageType,
      };

      socket.emit('sendMessage', messageData);

      socket.on('messageSent', (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지 전송 성공')),
        );
        _disconnectSocket();
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 오류')),
      );
    }
  }

  void _navigateToMissionCertification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MissionCertificationScreen(mId: widget.mId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Sending Photo"),
          backgroundColor: Colors.lightBlue[400],
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightBlue[400]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Send Photo", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _disconnectSocket();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: SingleChildScrollView(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _textController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: "메시지 입력",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _sendMessage,
                        child: Text("사진 보내기"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[400],
                          minimumSize: Size(120, 50),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToMissionCertification,
                        child: Text("인증 요청"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[400],
                          minimumSize: Size(120, 50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}