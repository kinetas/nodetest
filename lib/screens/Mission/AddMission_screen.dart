import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MissionProvider.dart';
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
  bool isRoomSelected = false;

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
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    final missionData = {
      'title': missionNameController.text,
      'dueDate': selectedDate,
      'hour': selectedHour,
      'minute': selectedMinute,
      'isAllDay': isAllDay,
      'isPersonalMission': isPersonalMission,
    };

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
    final Color primaryColor = Colors.lightBlue[300]!;
    final Color backgroundColor = Colors.white;
    final Color accentColor = Colors.lightBlue[50]!;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),

                // Mission Name
                _buildTextInput(label: "미션 이름", hint: "미션 이름을 입력하세요"),

                SizedBox(height: 15),

                // Time Setting
                Text(
                  "시간 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: primaryColor,
                  ),
                  onPressed: _openTimeSettingScreen,
                  icon: Icon(Icons.timer, color: primaryColor),
                  label: Text(
                    selectedDate != null
                        ? "${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일 " +
                        (isAllDay ? "" : "${selectedHour.toString().padLeft(2, '0')}시 ${selectedMinute.toString().padLeft(2, '0')}분")
                        : "⏱️ 시간 설정",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    Text("알람 설정", style: TextStyle(color: primaryColor)),
                  ],
                ),
                Divider(),

                // Sharing Settings
                Text(
                  "공유 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
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
                    Text("개인 미션", style: TextStyle(color: primaryColor)),
                  ],
                ),
                if (!isPersonalMission)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isRoomSelected = true;
                      });
                    },
                    child: Text("공유할 방 선택", style: TextStyle(color: primaryColor)),
                  ),
                Divider(),

                // Additional Settings
                Text(
                  "추가 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor)),
                      child: Text("카테고리 설정", style: TextStyle(color: primaryColor)),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor)),
                      child: Text("리워드 설정", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                Divider(),

                // Bottom Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: primaryColor)),
                      child: Text("취소", style: TextStyle(color: primaryColor)),
                    ),
                    ElevatedButton(
                      onPressed: saveMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildTextInput({required String label, required String hint}) {
    final Color primaryColor = Colors.lightBlue[300]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        SizedBox(height: 5),
        TextField(
          controller: missionNameController,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.lightBlue[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ],
    );
  }
}