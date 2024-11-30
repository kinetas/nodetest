// import 'package:flutter/material.dart';
// import '../Mission/AddMission_screen.dart';
// import '../Mission/MissionCertification_screen.dart';
//
// class ChatRoomScreen extends StatefulWidget {
//   final int chatId;
//
//   ChatRoomScreen({required this.chatId});
//
//   @override
//   _ChatRoomScreenState createState() => _ChatRoomScreenState();
// }
//
// class _ChatRoomScreenState extends State<ChatRoomScreen> {
//   final List<String> _messages = []; // 메시지 리스트
//   final TextEditingController _controller = TextEditingController();
//   bool _showBottomWidget = false; // 하단 위젯 표시 여부
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // 배경색 흰색으로 설정
//       appBar: AppBar(
//         title: Text('채팅방 ${widget.chatId}'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.exit_to_app),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: _messages.isEmpty
//                     ? Center(
//                   child: Text(
//                     '메시지가 없습니다.',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//                     : ListView.builder(
//                   reverse: true,
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     final message = _messages[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8.0, horizontal: 16.0),
//                       child: Align(
//                         alignment: Alignment.centerRight,
//                         child: Container(
//                           padding: EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Text(
//                             message,
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     // 메시지 입력창 왼쪽의 + 버튼
//                     IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: () {
//                         setState(() {
//                           _showBottomWidget = !_showBottomWidget; // 하단 팝업 토글
//                         });
//                       },
//                       color: Colors.blueAccent, // + 버튼 색상
//                     ),
//                     SizedBox(width: 8), // + 버튼과 메시지 입력창 사이 간격
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           hintText: '메시지를 입력하세요...',
//                           border: OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: Icon(Icons.send),
//                             onPressed: () {
//                               setState(() {
//                                 if (_controller.text.isNotEmpty) {
//                                   _messages.insert(0, _controller.text);
//                                   _controller.clear();
//                                 }
//                               });
//                             },
//                             color: Colors.blueAccent, // 전송 버튼 색상
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_showBottomWidget)
//             Positioned(
//               bottom: 80,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildCircleButton(
//                               context, Icons.add, '미션생성', () => _openMissionCreateScreen()),
//                           _buildCircleButton(
//                               context, Icons.check_circle, '미션인증', () => _openMissionVerifyScreen()),
//                           _buildCircleButton(
//                               context, Icons.request_page, '미션요청', () => _openMissionRequestScreen()),
//                           _buildCircleButton(
//                               context, Icons.card_giftcard, '리워드요청', () => _openRewardRequestScreen()),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCircleButton(
//       BuildContext context, IconData icon, String label, VoidCallback onPressed) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onPressed,
//           child: Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.blueAccent,
//             ),
//             child: Icon(icon, color: Colors.white),
//           ),
//         ),
//         SizedBox(height: 4),
//         TextButton(
//           onPressed: onPressed,
//           child: Text(
//             label,
//             style: TextStyle(color: Colors.black),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _openMissionCreateScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => AddMissionScreen()),
//     );
//   }
//
//   void _openMissionVerifyScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MissionVerifyScreen()),
//     );
//   }
//
//   void _openMissionRequestScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MissionRequestScreen()),
//     );
//   }
//
//   void _openRewardRequestScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RewardRequestScreen()),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Mission/AddMission_screen.dart';
import '../Mission/MissionCertification_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId; // 방 ID
  final String chatTitle; // 방 제목
  final String userId; // 사용자 ID

  ChatRoomScreen({required this.chatId, required this.chatTitle, required this.userId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  List<Map<String, dynamic>> messages = []; // 메시지 목록
  TextEditingController _messageController = TextEditingController(); // 메시지 입력 필드
  bool isLoading = true; // 로딩 상태
  bool _showBottomWidget = false; // 하단 팝업 표시 여부

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // 메시지 불러오기
  }

  Future<void> _fetchMessages() async {
    const String apiUrl = 'http://54.180.54.31:3000/api/getMessages';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'r_id': widget.chatId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(responseData['messages']);
          isLoading = false;
        });
      } else {
        print('메시지 불러오기 실패: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('메시지 불러오기 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    const String apiUrl = 'http://54.180.54.31:3000/api/sendMessage';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'r_id': widget.chatId,
          'u1_id': widget.userId, // 현재 사용자 ID
          'u2_id': 'recipient-id', // 상대방 사용자 ID
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          messages.insert(0, {
            'u1_id': responseData['u1_id'],
            'message': responseData['message'],
            'send_date': responseData['send_date'],
          });
          _messageController.clear(); // 입력 필드 초기화
        });
      } else {
        print('메시지 보내기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('메시지 보내기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      appBar: AppBar(
        title: Text(widget.chatTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 메시지 리스트
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? Center(
                  child: Text(
                    '메시지가 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'] ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                message['send_date'] ?? '',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 메시지 입력창
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // + 버튼
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _showBottomWidget = !_showBottomWidget;
                        });
                      },
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              if (_messageController.text.isNotEmpty) {
                                _sendMessage(_messageController.text);
                              }
                            },
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 하단 팝업
          if (_showBottomWidget)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircleButton(
                              context, Icons.add, '미션생성', _openMissionCreateScreen),
                          _buildCircleButton(
                              context, Icons.check_circle, '미션인증', _openMissionVerifyScreen),
                          _buildCircleButton(
                              context, Icons.request_page, '미션요청', _openMissionRequestScreen),
                          _buildCircleButton(
                              context, Icons.card_giftcard, '리워드요청', _openRewardRequestScreen),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
      BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _openMissionCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMissionScreen()),
    );
  }

  void _openMissionVerifyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MissionVerifyScreen()),
    );
  }

  void _openMissionRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MissionRequestScreen()),
    );
  }

  void _openRewardRequestScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RewardRequestScreen()),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// 각 화면 예제 클래스 (간단한 화면 내용)
class MissionCreateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 생성')),
      body: Center(child: Text('미션 생성 화면')),
    );
  }
}

class MissionVerifyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 인증')),
      body: Center(child: Text('미션 인증 화면')),
    );
  }
}

class MissionRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('미션 요청')),
      body: Center(child: Text('미션 요청 화면')),
    );
  }
}

class RewardRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('리워드 요청')),
      body: Center(child: Text('리워드 요청 화면')),
    );
  }
}