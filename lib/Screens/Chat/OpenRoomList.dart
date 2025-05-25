/*
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart'; // ✅ Token 기반으로 변경
import 'EnterChatRoom.dart';

class OpenRoomList extends StatefulWidget {
  @override
  _OpenRoomListState createState() => _OpenRoomListState();
}

class _OpenRoomListState extends State<OpenRoomList> {
  List<dynamic> openRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOpenRooms();
  }

  Future<void> fetchOpenRooms() async {
    try {
      final response = await SessionTokenManager.get('http://27.113.11.48:3000/api/rooms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data is List) {
            openRooms = data.where((room) => room['r_type'] == 'open').toList();
          } else if (data is Map<String, dynamic> && data.containsKey('rooms')) {
            openRooms = (data['rooms'] as List).where((room) => room['r_type'] == 'open').toList();
          } else {
            print('⚠️ 예상치 못한 데이터 형식: $data');
          }
          isLoading = false;
        });
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.lightBlue))
            : openRooms.isEmpty
            ? Center(child: Text('오픈 채팅방이 없습니다.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)))
            : ListView.builder(
          itemCount: openRooms.length,
          itemBuilder: (context, index) {
            final room = openRooms[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(room['r_title'] ?? '제목 없음', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                subtitle: Text('방 ID: ${room['r_id']}', style: TextStyle(color: Colors.grey)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.lightBlue, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EnterChatRoom(roomData: room)));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import 'EnterChatRoom.dart';

class OpenRoomList extends StatefulWidget {
  @override
  _OpenRoomListState createState() => _OpenRoomListState();
}

class _OpenRoomListState extends State<OpenRoomList> {
  List<dynamic> openRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOpenRooms();
  }

  Future<void> fetchOpenRooms() async {
    try {
      final response = await SessionTokenManager.get('http://27.113.11.48:3000/nodetest/api/rooms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          openRooms = (data is List)
              ? data.where((room) => room['r_type'] == 'open').toList()
              : (data['rooms'] as List).where((room) => room['r_type'] == 'open').toList();
          isLoading = false;
        });
      } else {
        print('❌ 서버 오류: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 그라데이션 제거
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          : openRooms.isEmpty
          ? Center(
        child: Text(
          '오픈 채팅방이 없습니다.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: openRooms.length,
        itemBuilder: (context, index) {
          final room = openRooms[index];
          return Card(
            color: Colors.white, // ✅ 카드 배경 고정
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue[100],
                child: Text(
                  (room['r_title'] ?? '방')[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
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
            ),
          );
        },
      ),
    );
  }
}