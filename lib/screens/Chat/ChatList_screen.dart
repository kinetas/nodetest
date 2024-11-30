import 'package:flutter/material.dart';
import 'ChatRoomScreen.dart';

class ChatList extends StatelessWidget {
  final List<Map<String, String>> chatList;

  ChatList({required this.chatList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final chat = chatList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(chat['title']![0]), // 첫 글자를 아이콘으로 표시
          ),
          title: Text(chat['title'] ?? 'Unknown'),
          subtitle: Text(chat['lastMessage'] ?? ''),
          trailing: Text(chat['time'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  chatId: chat['id'].toString(), // int -> String 변환
                ),
              ),
            );
          },
        );
      },
    );
  }
}