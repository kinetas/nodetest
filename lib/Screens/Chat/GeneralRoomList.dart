import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 파싱을 위해 필요
import '../../SessionCookieManager.dart'; // SessionCookieManager 경로에 맞게 수정
import 'EnterChatRoom.dart';
import 'FixChat.dart'; // FixChat 클래스 import

class GeneralRoomList extends StatefulWidget {
  @override
  _GeneralRoomListState createState() => _GeneralRoomListState();
}

class _GeneralRoomListState extends State<GeneralRoomList> {
  List<dynamic> generalRooms = []; // 일반 채팅방 리스트 저장
  bool isLoading = true; // 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    fetchGeneralRooms(); // 채팅방 리스트 가져오기
  }

  Future<void> fetchGeneralRooms() async {
    try {
      final url = 'http://27.113.11.48:3000/api/rooms';
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          // 반환 값이 리스트인 경우
          setState(() {
            generalRooms = data.where((room) => room['r_type'] == 'general').toList();
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> && data.containsKey('rooms')) {
          // 반환 값이 객체이며, rooms 키가 있는 경우
          setState(() {
            generalRooms = (data['rooms'] as List)
                .where((room) => room['r_type'] == 'general')
                .toList();
            isLoading = false;
          });
        } else {
          print('Unexpected data format: $data');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching general rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // AppBar 높이를 0으로 설정하여 숨김
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 표시
          : generalRooms.isEmpty
          ? Center(child: Text('일반 채팅방이 없습니다.')) // 리스트가 비어 있을 경우
          : ListView.builder(
        itemCount: generalRooms.length,
        itemBuilder: (context, index) {
          final room = generalRooms[index];
          return ListTile(
            title: Text(room['r_title'] ?? '제목 없음'), // 방 이름 출력
            subtitle: Text('방 ID: ${room['r_id']}'), // 방 ID 출력
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
                builder: (BuildContext context) {
                  return FixChat(
                    u2Id: room['u2_id'],
                    rType: room['r_type'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}