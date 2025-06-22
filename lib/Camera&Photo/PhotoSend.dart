import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../SessionTokenManager.dart';
import '../Screens/Mission/NewMissionScreen/MissionCertification_screen.dart';
import '../UserInfo/UserInfo_Id.dart';
import 'package:image/image.dart' as img;

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
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    print("🚀 [initState] PhotoSend 시작됨");
    _loadUserId();
  }

  @override
  void dispose() {
    print("🧹 [dispose] 정리 중...");
    if (socket.connected) {
      print("📤 [leaveRoom] 소켓 연결 종료 전 방 떠남");
      socket.emit('leaveRoom', {
        'r_id': widget.rId,
        'u1_id': _u1Id,
      });
      socket.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    print("🔍 [loadUserId] 사용자 ID 불러오는 중...");
    final userInfo = UserInfoId();
    final userId = await userInfo.fetchUserId();

    if (userId != null) {
      print("✅ [loadUserId] 사용자 ID 불러옴: $userId");
      setState(() {
        _u1Id = userId;
        _isLoading = false;
      });
      await _initializeSocket();
    } else {
      print("❌ [loadUserId] 사용자 ID 가져오기 실패");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유저 정보 조회 실패')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeSocket() async {
    print("🌐 [initializeSocket] 소켓 연결 시도");
    final token = await SessionTokenManager.getToken();
    print("🔐 JWT Token: $token");

    socket = IO.io(
      'http://13.125.65.151:3000/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setPath('/socket.io')
          .build(),
    );

    socket.onConnect((_) {
      print('✅ [onConnect] 소켓 연결 성공');
      setState(() => _isSocketConnected = true);
      socket.emit('joinRoom', {
        'r_id': widget.rId,
        'u1_id': _u1Id,
        'u2_id': widget.missionAuthenticationAuthority,
      });
    });

    socket.onDisconnect((_) {
      print('⚠️ [onDisconnect] 소켓 연결 끊김');
      setState(() => _isSocketConnected = false);
    });

    socket.on('errorMessage', (err) {
      print('❌ [errorMessage] 서버 오류: $err');
    });

    socket.connect();
    print("🔁 [connect] 소켓 연결 시도 완료");
  }

  Future<void> _handleSendAndCertify() async {
    print("📤 [인증 요청] 이미지+텍스트 전송 + 인증 화면 이동");

    if (!_isSocketConnected) {
      print("⚠️ 소켓 아직 연결 안됨");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소켓 연결이 아직 완료되지 않았습니다.')),
      );
      return;
    }

    try {
      final imageFile = File(widget.imagePath);
      final originalBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) throw Exception("이미지 디코딩 실패");

      final resized = img.copyResize(originalImage, width: 500);
      final resizedBytes = img.encodeJpg(resized, quality: 85);
      final base64Image = base64Encode(resizedBytes);
      final mimeType = _getMimeType(imageFile.path);

      final message = _textController.text.trim();
      final messageData = {
        'r_id': widget.rId,
        'u2_id': widget.missionAuthenticationAuthority,
        'message_contents': message.isNotEmpty ? message : null,
        'image': base64Image,
        'image_type': mimeType,
      };

      socket.emit('sendMessage', messageData);
      print("✅ [emit] sendMessage 완료");

      // 인증 화면 이동 후 결과 다이얼로그
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionCertificationScreen(mId: widget.mId),
        ),
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("미션 인증"),
          content: Text("미션이 인증되었습니다!"),
          actions: [
            TextButton(
              onPressed: () async {
                 // 다이얼로그 닫기

                final userId = _u1Id ?? '알수없음';
                final messageText = '$userId 님이 미션을 완료했어요! 돌아오셔서 확인해주세요!';

                if (!_isSocketConnected || !(socket.connected)) {
                  print("🔄 [재연결] 소켓이 연결되어 있지 않아 재연결 시도");
                  await _initializeSocket();
                }

                await Future.delayed(Duration(milliseconds: 500)); // 소켓 연결 시간 확보

                socket.emit('sendMessage', {
                  'r_id': widget.rId,
                  'u2_id': widget.u2Id,
                  'message_contents': messageText,
                  'image': null,
                  'image_type': null,
                });

                print("📢 [메시지 전송] $messageText");
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst); // 전체 화면 닫기
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ [에러] 메시지 전송 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    }
  }

  String _getMimeType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("사진 전송"), backgroundColor: Colors.lightBlue),
        body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("사진 전송", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print("🔙 [Back]");
            socket.emit('leaveRoom', {
              'r_id': widget.rId,
              'u1_id': _u1Id,
            });
            socket.dispose();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text("사진 확대 보기")),
                        body: Center(child: Image.file(File(widget.imagePath))),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.imagePath),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: "메시지 입력 (선택)",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSendAndCertify,
                child: Text("미션 인증"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  minimumSize: Size(300, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}