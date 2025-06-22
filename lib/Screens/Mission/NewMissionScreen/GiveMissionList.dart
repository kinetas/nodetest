import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../SessionTokenManager.dart';
import 'MissionClick.dart';

class GiveMissionList extends StatefulWidget {
  const GiveMissionList({super.key});

  @override
  State<GiveMissionList> createState() => _GiveMissionListState();
}

class _GiveMissionListState extends State<GiveMissionList> {
  List<Map<String, dynamic>> missions = [];
  bool isLoading = true;
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    initSocket();
    fetchMissions();
  }

  Future<void> initSocket() async {
    final token = await SessionTokenManager.getToken();
    socket = IO.io(
      'http://13.125.65.151:3000/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setPath('/socket.io')
          .build(),
    );
    socket?.connect();
    socket?.onConnect((_) => print('🟢 Socket connected'));
    socket?.onDisconnect((_) => print('🔌 Socket disconnected'));
  }

  Future<void> sendNudgeMessage(String rId, String u2Id, String mTitle) async {
    final message = {
      'r_id': rId,
      'u2_id': u2Id,
      'message_contents': "친구가 '$mTitle' 미션 재촉의 메세지를 보내왔어요!!"
          " '$mTitle' 미션 인증 좀 해줘~ 🙏",
    };
    if (socket?.connected ?? false) {
      socket?.emit('sendMessage', message);
      print("📨 [Socket] Nudge message sent: $message");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("재촉 메시지를 보냈어요!")));
    } else {
      print("❌ Socket not connected");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("소켓 연결 실패. 재접속 필요.")));
    }
  }

  Future<void> fetchMissions() async {
    try {
      final response = await SessionTokenManager.get(
        'http://13.125.65.151:3000/nodetest/api/missions/missions/friendAssigned',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List missionsRaw = data['missions'] ?? [];

        final List<Map<String, dynamic>> filtered = missionsRaw
            .where((m) => m['m_status'] == '진행중')
            .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
            .toList();

        setState(() {
          missions = filtered;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  DateTime? parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchMissions,
      child: isLoading
          ? ListView(children: const [SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))])
          : missions.isEmpty
          ? ListView(children: const [SizedBox(height: 200, child: Center(child: Text('진행 중인 친구 미션이 없습니다.')))])
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          final deadline = parseDateTime(mission['m_deadline'])?.toLocal();
          final formattedDate = deadline != null
              ? DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(deadline)
              : '날짜 없음';
          final formattedTime = deadline != null
              ? DateFormat('HH:mm').format(deadline)
              : '시간 없음';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("미션 '${mission['m_title']}'"),
                    content: const Text("이 친구에게 인증을 재촉할까요?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          sendNudgeMessage(
                            mission['r_id'],
                            mission['u2_id'],
                            mission['m_title'],
                          );
                        },
                        child: const Text("미션 인증 재촉하기 🙃"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("닫기"),
                      ),
                    ],
                  ),
                );
              },
              title: Text(
                mission['m_title'] ?? '제목 없음',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('카테고리: ${mission['category'] ?? '없음'}'),
                    Text('마감일: $formattedDate $formattedTime'),
                    if (mission['m_extended'] == true)
                      const Text('✅ 연장된 미션입니다.', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
              trailing: const Icon(Icons.group, color: Colors.lightBlue),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}