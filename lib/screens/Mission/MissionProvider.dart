import 'package:flutter/material.dart';

class MissionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _missions = [];
  bool _isAchievementPanelOpen = false;

  List<Map<String, dynamic>> get missions => _missions;
  bool get isAchievementPanelOpen => _isAchievementPanelOpen;

  void addMission(Map<String, dynamic> mission) {
    _missions.add(mission);
    notifyListeners();
  }

  void toggleAchievementPanel() {
    _isAchievementPanelOpen = !_isAchievementPanelOpen;
    notifyListeners();
  }
}
