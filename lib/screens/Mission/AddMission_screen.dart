import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용
import 'MissionProvider.dart'; // MissionProvider 추가
import 'TimeSetting_screen.dart';

class AddMissionScreen extends StatefulWidget {
  @override
  _AddMissionScreenState createState() => _AddMissionScreenState();
}

class _AddMissionScreenState extends State<AddMissionScreen> {
  bool alarm = false;
  bool isAllDay = false;
  bool isPersonalMission = false;
  TextEditingController missionNameController = TextEditingController();

  DateTime? selectedDate;
  int? selectedHour;
  int? selectedMinute;
  bool isRoomSelected = false; // Flag to track room selection

  void saveMission() {
    String errorMessage = '';

    if (missionNameController.text.isEmpty) {
      errorMessage = '제목을 입력하세요';
    } else if (selectedDate == null || (selectedHour == null && !isAllDay)) {
      errorMessage = '시간을 설정하세요';
    }

    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    // 오류가 없을 때만 미션 저장
    final missionData = {
      'title': missionNameController.text,
      'dueDate': selectedDate,
      'hour': selectedHour,
      'minute': selectedMinute,
      'isAllDay': isAllDay,
      'isPersonalMission': isPersonalMission,
    };

    // Provider를 통해 미션 데이터 저장
    Provider.of<MissionProvider>(context, listen: false).addMission(missionData);

    Navigator.pop(context);
  }

  Future<void> _openTimeSettingScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeSettingScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        selectedDate = result['selectedDate'];
        selectedHour = result['selectedHour'];
        selectedMinute = result['selectedMinute'];
        isAllDay = result['isAllDay'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "미션 설정",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),

                // Mission Name
                Text(
                  "미션 이름",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                TextField(
                  controller: missionNameController,
                  decoration: InputDecoration(
                    hintText: "미션 이름을 입력하세요",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(height: 15),

                // Time Setting
                Text(
                  "시간 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // primary 대신 backgroundColor 사용
                  ),
                  onPressed: _openTimeSettingScreen,
                  icon: Icon(Icons.timer),
                  label: Text(
                    selectedDate != null
                        ? "${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일 " +
                        (isAllDay ? "" : "${selectedHour.toString().padLeft(2, '0')}시 ${selectedMinute.toString().padLeft(2, '0')}분")
                        : "⏱️ 시간 설정",
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: alarm,
                      onChanged: (value) {
                        setState(() {
                          alarm = value!;
                        });
                      },
                    ),
                    Text("알람 설정"),
                  ],
                ),
                Divider(),

                // Personal Mission and Room Selection
                Text(
                  "공유 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isPersonalMission,
                      onChanged: (value) {
                        setState(() {
                          isPersonalMission = value ?? false;
                          if (isPersonalMission) {
                            isRoomSelected = false;
                          }
                        });
                      },
                    ),
                    Text("개인 미션"),
                  ],
                ),
                if (!isPersonalMission)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isRoomSelected = true;
                      });
                    },
                    child: Text("공유할 방 선택"),
                  ),
                Divider(),

                // Additional Settings
                Text(
                  "추가 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: Text("카테고리 설정")),
                    SizedBox(width: 10),
                    OutlinedButton(onPressed: () {}, child: Text("리워드 설정")),
                  ],
                ),
                Divider(),

                // Bottom Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("취소"),
                    ),
                    ElevatedButton(
                      onPressed: saveMission,
                      child: Text("저장"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}