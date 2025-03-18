import 'package:flutter/material.dart';
import 'dart:convert'; // JSON 파싱용
import '../../SessionCookieManager.dart';

class AchievementPanel extends StatefulWidget {
  final VoidCallback onClose;

  AchievementPanel({required this.onClose});

  @override
  _AchievementPanelState createState() => _AchievementPanelState();
}

class _AchievementPanelState extends State<AchievementPanel> {
  String _currentAchievementPeriod = "주간"; // Default period
  final List<String> achievementPeriods = ['일일', '주간', '월간', '연간'];
  Map<String, double> achievementRates = {
    '일일': 0.0,
    '주간': 0.0,
    '월간': 0.0,
    '연간': 0.0,
  };
  bool isLoading = true;

  double get _currentAchievementRate => achievementRates[_currentAchievementPeriod] ?? 0.0;

  String getAchievementEmoji(double rate) {
    if (rate < 0.3) return '🥺';
    if (rate < 0.5) return '😦';
    if (rate < 0.7) return '😊';
    if (rate < 0.9) return '🥰';
    return '😎';
  }

  @override
  void initState() {
    super.initState();
    _fetchAchievementRates();
  }

  Future<void> _fetchAchievementRates() async {
    setState(() {
      isLoading = true;
    });

    try {
      // URL 및 파라미터 매핑
      Map<String, Map<String, String>> urlsAndKeys = {
        '일일': {'url': 'http://27.113.11.48:3000/result/daily', 'key': 'dailyRate'},
        '주간': {'url': 'http://27.113.11.48:3000/result/weekly', 'key': 'weeklyRate'},
        '월간': {'url': 'http://27.113.11.48:3000/result/monthly', 'key': 'monthlyRate'},
        '연간': {'url': 'http://27.113.11.48:3000/result/yearly', 'key': 'yearlyRate'},
      };

      for (var period in achievementPeriods) {
        final response = await SessionCookieManager.get(urlsAndKeys[period]!['url']!);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            achievementRates[period] = responseData[urlsAndKeys[period]!['key']]?.toDouble() ?? 0.0;
          });
        } else {
          print('[$period] 데이터 가져오기 실패: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('달성률 데이터 가져오기 오류: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
      height: MediaQuery.of(context).size.height / 3,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlue.shade100,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '달성률 보기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.blueGrey),
                onPressed: widget.onClose,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.lightBlue),
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
                  '📊 $_currentAchievementPeriod 달성률 ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue.shade700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.lightBlue),
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
                      value: _currentAchievementRate / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${_currentAchievementRate.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${_currentAchievementRate.toInt()}%',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    getAchievementEmoji(_currentAchievementRate / 100),
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}