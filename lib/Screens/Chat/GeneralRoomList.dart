import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 수정
import 'EnterChatRoom.dart';
import 'FixChat.dart';

class GeneralRoomList extends StatefulWidget {
  @override
  _GeneralRoomListState createState() => _GeneralRoomListState();
}

class _GeneralRoomListState extends State<GeneralRoomList> {
  List<dynamic> generalRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGeneralRooms();
  }

  Future<void> fetchGeneralRooms() async {
    try {
      final url = 'http://27.113.11.48:3000/api/rooms';

      final response = await SessionTokenManager.get(url); // ✅ headers 안 넘김

      print('📥 일반 채팅방 목록 응답: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            generalRooms = data.where((room) => room['r_type'] == 'general').toList();
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> && data.containsKey('rooms')) {
          setState(() {
            generalRooms = (data['rooms'] as List)
                .where((room) => room['r_type'] == 'general')
                .toList();
            isLoading = false;
          });
        } else {
          print('❗️ Unexpected data format: $data');
          setState(() => isLoading = false);
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching general rooms: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0), // 숨김
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : generalRooms.isEmpty
          ? Center(child: Text('일반 채팅방이 없습니다.'))
          : ListView.builder(
        itemCount: generalRooms.length,
        itemBuilder: (context, index) {
          final room = generalRooms[index];
          return ListTile(
            title: Text(room['r_title'] ?? '제목 없음'),
            subtitle: Text('방 ID: ${room['r_id']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterChatRoom(roomData: room),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => FixChat(
                  u2Id: room['u2_id'],
                  rType: room['r_type'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}