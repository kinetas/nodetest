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
          setState(() {
            openRooms = data.where((room) => room['r_type'] == 'open').toList();
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> && data.containsKey('rooms')) {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
          ),
        )
            : openRooms.isEmpty
            ? Center(
          child: Text(
            '오픈 채팅방이 없습니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        )
            : ListView.builder(
          itemCount: openRooms.length,
          itemBuilder: (context, index) {
            final room = openRooms[index];
            return Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  room['r_title'] ?? '제목 없음',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                subtitle: Text(
                  '방 ID: ${room['r_id']}',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.lightBlue,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EnterChatRoom(roomData: room),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}