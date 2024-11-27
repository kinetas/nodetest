import 'package:flutter/material.dart';

class MissionCertificationScreen extends StatelessWidget {
  final String missionTitle;
  final String missionDescription;
  final Function onSubmit;

  const MissionCertificationScreen({
    Key? key,
    required this.missionTitle,
    required this.missionDescription,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 인증'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              missionTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              missionDescription,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onSubmit();
              },
              child: Text('인증 완료'),
            ),
          ],
        ),
      ),
    );
  }
}