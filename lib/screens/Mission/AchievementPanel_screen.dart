import 'package:flutter/material.dart';

class AchievementPanel extends StatefulWidget {
  final VoidCallback onClose;

  AchievementPanel({required this.onClose});

  @override
  _AchievementPanelState createState() => _AchievementPanelState();
}

class _AchievementPanelState extends State<AchievementPanel> {
  String _currentAchievementPeriod = "주간"; // Default period
  final Map<String, double> achievementRates = {
    '일일': 0.2, // 20%
    '주간': 0.5, // 50%
    '월간': 0.7, // 70%
    '연간': 0.9, // 90%
  };
  final List<String> achievementPeriods = ['일일', '주간', '월간', '연간'];

  double get _currentAchievementRate => achievementRates[_currentAchievementPeriod] ?? 0.0;

  String getAchievementEmoji(double rate) {
    if (rate < 0.3) return '🥺';
    if (rate < 0.5) return '😦';
    if (rate < 0.7) return '😊';
    if (rate < 0.9) return '🥰';
    return '😎';
  }

  void _changeAchievementPeriod(bool isNext) {
    int currentIndex = achievementPeriods.indexOf(_currentAchievementPeriod);
    int newIndex = (currentIndex + (isNext ? 1 : -1)) % achievementPeriods.length;
    if (newIndex < 0) newIndex = achievementPeriods.length - 1;
    setState(() {
      _currentAchievementPeriod = achievementPeriods[newIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('달성률 보기', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => _changeAchievementPeriod(false),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: achievementPeriods
                            .map((period) => ListTile(
                          title: Text(period),
                          onTap: () {
                            setState(() {
                              _currentAchievementPeriod = period;
                            });
                            Navigator.pop(context);
                          },
                        ))
                            .toList(),
                      );
                    },
                  );
                },
                child: Text(
                  ' 📊 $_currentAchievementPeriod 달성률 ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () => _changeAchievementPeriod(true),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: _currentAchievementRate,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text('${(_currentAchievementRate * 100).toInt()}%', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('00/${(_currentAchievementRate * 100).toInt()}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(getAchievementEmoji(_currentAchievementRate), style: TextStyle(fontSize: 24)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}