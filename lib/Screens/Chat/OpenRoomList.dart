import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../SessionTokenManager.dart';
import 'EnterChatRoom.dart';
import 'FixChat.dart';

class OpenRoomList extends StatefulWidget {
  @override
  _OpenRoomListState createState() => _OpenRoomListState();
}

class _OpenRoomListState extends State<OpenRoomList> {
  List<Map<String, dynamic>> openRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOpenRooms();
  }

  Future<void> fetchOpenRooms() async {
    setState(() => isLoading = true);
    final resp = await SessionTokenManager.get('http://13.125.65.151:3000/nodetest/api/rooms');
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final rooms = ((data is List) ? data : data['rooms'])
          .where((r) => r['r_type'] == 'open')
          .cast<Map<String, dynamic>>()
          .toList();

      for (var room in rooms) {
        final rId = room['r_id'];
        final lastResp = await SessionTokenManager.get(
            'http://13.125.65.151:3000/nodetest/chat/last-message/$rId');
        if (lastResp.statusCode == 200) {
          final msg = json.decode(lastResp.body);
          room['last_message'] = msg['message_contents'] ?? '';
          room['last_send_date'] = msg['send_date'];
        } else {
          room['last_message'] = '';
          room['last_send_date'] = null;
        }
      }

      // 최신 메시지 순 정렬
      rooms.sort((a, b) {
        final aTime = DateTime.tryParse(a['last_send_date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b['last_send_date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // 최신이 먼저
      });

      setState(() {
        openRooms = rooms;
        isLoading = false;
      });
    } else {
      print('❌ 서버 오류: ${resp.statusCode}');
      setState(() => isLoading = false);
    }
  }

  String _formatTime(String? dtStr) {
    if (dtStr == null) return '';
    final dt = DateTime.tryParse(dtStr)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return DateFormat('a h:mm', 'ko_KR').format(dt);
    if (diff.inDays == 1) return '어제';
    return DateFormat('M월 d일').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          : openRooms.isEmpty
          ? Center(
        child: Text(
          '오픈 채팅방이 없습니다.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchOpenRooms,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 8),
          separatorBuilder: (_, __) =>
              Divider(indent: 72, endIndent: 16, color: Colors.grey[300]),
          itemCount: openRooms.length,
          itemBuilder: (ctx, i) {
            final room = openRooms[i];
            final title = room['r_title'] ?? '제목 없음';
            final lastMsg = room['last_message'] ?? '메시지 없음';
            final updatedAt = _formatTime(room['last_send_date']);
            final unread = room['unread_count'] ?? 0;

            return ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnterChatRoom(roomData: room),
                  ),
                );
                fetchOpenRooms(); // 돌아왔을 때 새로고침
              },
              onLongPress: () {
                FixChat.show(
                  context,
                  u2Id: room['u2_id'],
                  rType: room['r_type'],
                  onUpdated: () {
                    fetchOpenRooms(); // ✅ 방 수정/삭제 후 리스트 자동 새로고침
                  },
                );
              },
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.lightBlue[100],
                child: Text(
                  title[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                lastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(updatedAt, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  if (unread > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$unread',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}