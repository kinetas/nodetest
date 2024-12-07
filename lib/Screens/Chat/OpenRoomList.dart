import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 파싱을 위해 필요
import '../../SessionCookieManager.dart'; // SessionCookieManager 경로에 맞게 수정
import 'EnterChatRoom.dart';

class OpenRoomList extends StatefulWidget {
  @override
  _OpenRoomListState createState() => _OpenRoomListState();
}

class _OpenRoomListState extends State<OpenRoomList> {
  List<dynamic> openRooms = []; // 오픈 채팅방 리스트 저장
  bool isLoading = true; // 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    fetchOpenRooms(); // 채팅방 리스트 가져오기
  }

  Future<void> fetchOpenRooms() async {
    try {
      final url = 'http://54.180.54.31:3000/api/rooms';
      final response = await SessionCookieManager.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          // 반환 값이 리스트인 경우
          setState(() {
            openRooms = data.where((room) => room['r_type'] == 'open').toList();
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> && data.containsKey('rooms')) {
          // 반환 값이 객체이며, rooms 키가 있는 경우
          setState(() {
            openRooms = (data['rooms'] as List)
                .where((room) => room['r_type'] == 'open')
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
      print('Error fetching open rooms: $e');
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
          : openRooms.isEmpty
          ? Center(child: Text('오픈 채팅방이 없습니다.')) // 리스트가 비어 있을 경우
          : ListView.builder(
        itemCount: openRooms.length,
        itemBuilder: (context, index) {
          final room = openRooms[index];
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
          );
        },
      ),
    );
  }
}