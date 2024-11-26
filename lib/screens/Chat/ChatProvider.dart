import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  // 일반 채팅방 리스트
  List<Map<String, dynamic>> generalChatList = [];

  // 미션 채팅방 리스트
  List<Map<String, dynamic>> missionChatList = [];

  // 일반 채팅방 추가
  void addGeneralChat(Map<String, dynamic> chatData) {
    generalChatList.add(chatData);
    notifyListeners(); // 데이터가 변경되었음을 알림
  }

  // 미션 채팅방 추가
  void addMissionChat(Map<String, dynamic> chatData) {
    missionChatList.add(chatData);
    notifyListeners();
  }

  // 일반 채팅방 삭제
  void removeGeneralChat(int index) {
    generalChatList.removeAt(index);
    notifyListeners();
  }

  // 미션 채팅방 삭제
  void removeMissionChat(int index) {
    missionChatList.removeAt(index);
    notifyListeners();
  }
}