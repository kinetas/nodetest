import 'package:flutter/material.dart';

class MissionList extends StatelessWidget {
  final List<Map<String, dynamic>> missions;

  MissionList({required this.missions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return ListTile(
          title: Text(mission['title']),
          subtitle: Text("${mission['dueDate']}"),
        );
      },
    );
  }
}
