import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
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
      final url = 'http://27.113.11.48:3000/nodetest/api/rooms';
      final response = await SessionTokenManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          generalRooms = (data is List)
              ? data.where((room) => room['r_type'] == 'general').toList()
              : (data['rooms'] as List)
              .where((room) => room['r_type'] == 'general')
              .toList();
          isLoading = false;
        });
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
      backgroundColor: Colors.white, // ✅ 전체 배경 흰색
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          : generalRooms.isEmpty
          ? Center(
        child: Text(
          '일반 채팅방이 없습니다.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: generalRooms.length,
        itemBuilder: (context, index) {
          final room = generalRooms[index];
          return Card(
            color: Colors.white, // ✅ 카드 배경 흰색
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Text(
                  (room['r_title'] ?? '방')[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
              title: Text(
                room['r_title'] ?? '제목 없음',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                '방 ID: ${room['r_id']}',
                style: TextStyle(color: Colors.black87),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.lightBlue, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnterChatRoom(roomData: room)),
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
            ),
          );
        },
      ),
    );
  }
}