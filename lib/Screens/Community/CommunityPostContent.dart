import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class CommunityPostContent extends StatefulWidget {
  final String crNum;
  final String crTitle;
  final String crStatus;

  CommunityPostContent({
    required this.crNum,
    required this.crTitle,
    required this.crStatus,
  });

  @override
  _CommunityPostContentState createState() => _CommunityPostContentState();
}

class _CommunityPostContentState extends State<CommunityPostContent> {
  String deadline = "로딩 중...";
  String content = "로딩 중...";
  String? createdAt; // 작성일시
  String? nickname;  // 닉네임
  String? profileImageUrl; // 프로필 이미지(없으면 null)
  int? viewCount;
  int? recommendCount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostContent();
  }

  Future<void> fetchPostContent() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list';
    try {
      final response = await SessionTokenManager.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['missions'];
        final mission = data.firstWhere(
              (mission) => mission['cr_num'] == widget.crNum,
          orElse: () => null,
        );
        if (mission != null) {
          setState(() {
            deadline = mission['deadline'] ?? '기한 없음';
            content = mission['contents'] ?? '내용 없음';

            // 서버에서 오는 정보만 표시
            nickname = mission['nickname'];
            createdAt = mission['created_at'];
            profileImageUrl = mission['profile_image_url'];
            viewCount = mission['view_count'];
            recommendCount = mission['recommend_count'];
            isLoading = false;
          });
        } else {
          setState(() {
            content = '해당 미션을 찾을 수 없습니다.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          content = '데이터를 가져오는데 실패했습니다.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        content = '오류가 발생했습니다. 다시 시도해주세요.';
        isLoading = false;
      });
    }
  }

  String _getStatusLabel(String status) {
    if (status == 'acc') return '매칭 완료';
    if (status == 'match') return '매칭 중';
    return '상태 알 수 없음';
  }

  // 날짜 포맷 (yyyy/MM/dd HH:mm)
  String? formatDate(String? date) {
    if (date == null) return null;
    try {
      final dt = DateTime.parse(date).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return null;
    }
  }

  // 마감일 포맷 (yyyy년 M월 d일 H시 m분)
  String formatDeadline(String deadline) {
    try {
      final dateTime = DateTime.parse(deadline).toLocal();
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
          '${dateTime.hour}시 ${dateTime.minute}분';
    } catch (e) {
      return deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatched = widget.crStatus == 'acc';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: const Text(
          '게시글 상세',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]))
          : SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // [유저 정보 영역] (존재하는 정보만 표시)
                  if (nickname != null || profileImageUrl != null || createdAt != null || viewCount != null || recommendCount != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
                      child: Row(
                        children: [
                          // 프로필 이미지 (있을 때만)
                          if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                profileImageUrl!,
                                width: 44, height: 44, fit: BoxFit.cover,
                              ),
                            ),
                          if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                            SizedBox(width: 10),
                          // 닉네임, 날짜, 조회/추천
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (nickname != null && nickname!.isNotEmpty)
                                  Text(
                                    nickname!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                if (createdAt != null && createdAt!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatDate(createdAt!)!,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    if (viewCount != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6.0, top: 2),
                                        child: Text(
                                          '조회 ${viewCount!}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ),
                                    if (recommendCount != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '추천 ${recommendCount!}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 상태/마감일 라벨
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.grey[200]
                                : Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(widget.crStatus),
                            style: TextStyle(
                              color: isMatched
                                  ? Colors.grey[600]
                                  : Colors.lightBlue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F3F8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFBFD7ED), width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.lightBlue, size: 15),
                              SizedBox(width: 5),
                              Text(
                                '마감일',
                                style: TextStyle(
                                  color: Colors.lightBlue[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                formatDeadline(deadline),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 제목
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                    child: Text(
                      widget.crTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // 본문 카드
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                          height: 1.7,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 하단 고정 미션 수락 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isMatched
                        ? null
                        : () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('미션 수락'),
                          content: Text('미션을 수락하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text('취소')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text('확인')),
                          ],
                        ),
                      );
                      if (result == true) {
                        await acceptMission();
                      }
                    },
                    child: Text(
                      '미션 수락하기',
                      style: TextStyle(fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMatched
                          ? Colors.grey[400]
                          : Colors.lightBlue[400],
                      minimumSize: Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptMission() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/accept';
    final body = json.encode({"cr_num": widget.crNum});
    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션이 수락되었습니다!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션 수락에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }
}

/* //유저 정보까지 가져오려 했으나 로딩시간이 너무 길어지는 문제 발생
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';
import '../../UserInfo/UserInfo_all.dart'; // ← 경로 반영!

class CommunityPostContent extends StatefulWidget {
  final String crNum;
  final String crTitle;
  final String crStatus;

  CommunityPostContent({
    required this.crNum,
    required this.crTitle,
    required this.crStatus,
  });

  @override
  _CommunityPostContentState createState() => _CommunityPostContentState();
}

class _CommunityPostContentState extends State<CommunityPostContent> {
  String deadline = "로딩 중...";
  String content = "로딩 중...";

  // 유저 정보(내 정보)
  String? userNickname;
  String? userProfileImageUrl;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchPostContent(),
      fetchUserInfo(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchUserInfo() async {
    final userInfoAll = UserInfoAll();
    final userInfo = await userInfoAll.fetchUserInfo();
    if (userInfo != null) {
      setState(() {
        userNickname = userInfo['nickname'];
        userProfileImageUrl = userInfo['profile_image_url'];
      });
    }
  }

  Future<void> fetchPostContent() async {
    final url = 'http://27.113.11.48:3000/nodetest/api/comumunity_missions/list';
    try {
      final response = await SessionTokenManager.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['missions'];
        final mission = data.firstWhere(
          (mission) => mission['cr_num'] == widget.crNum,
          orElse: () => null,
        );
        if (mission != null) {
          setState(() {
            deadline = mission['deadline'] ?? '기한 없음';
            content = mission['contents'] ?? '내용 없음';
          });
        } else {
          setState(() {
            content = '해당 미션을 찾을 수 없습니다.';
          });
        }
      } else {
        setState(() {
          content = '데이터를 가져오는데 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        content = '오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  String _getStatusLabel(String status) {
    if (status == 'acc') return '매칭 완료';
    if (status == 'match') return '매칭 중';
    return '상태 알 수 없음';
  }

  // 마감일 포맷 (yyyy년 M월 d일 H시 m분)
  String formatDeadline(String deadline) {
    try {
      final dateTime = DateTime.parse(deadline).toLocal();
      return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
          '${dateTime.hour}시 ${dateTime.minute}분';
    } catch (e) {
      return deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatched = widget.crStatus == 'acc';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: const Text(
          '게시글 상세',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.lightBlue[400]))
          : SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 내 정보로 유저 영역 표시
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
                    child: Row(
                      children: [
                        userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  userProfileImageUrl!,
                                  width: 44, height: 44, fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, size: 32, color: Colors.grey[700]),
                              ),
                        SizedBox(width: 10),
                        // 닉네임
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userNickname != null
                                  ? Text(
                                      userNickname!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 상태/마감일 라벨
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.grey[200]
                                : Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(widget.crStatus),
                            style: TextStyle(
                              color: isMatched
                                  ? Colors.grey[600]
                                  : Colors.lightBlue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F3F8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFBFD7ED), width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.lightBlue, size: 15),
                              SizedBox(width: 5),
                              Text(
                                '마감일',
                                style: TextStyle(
                                  color: Colors.lightBlue[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                formatDeadline(deadline),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 제목
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                    child: Text(
                      widget.crTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // 본문 카드
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        content,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                          height: 1.7,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 하단 고정 미션 수락 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isMatched
                        ? null
                        : () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('미션 수락'),
                                content: Text('미션을 수락하시겠습니까?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('취소')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('확인')),
                                ],
                              ),
                            );
                            if (result == true) {
                              await acceptMission();
                            }
                          },
                    child: Text(
                      '미션 수락하기',
                      style: TextStyle(fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMatched
                          ? Colors.grey[400]
                          : Colors.lightBlue[400],
                      minimumSize: Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> acceptMission() async {
    final url = 'http://27.113.11.48:3000/api/comumunity_missions/accept';
    final body = json.encode({"cr_num": widget.crNum});
    try {
      final response = await SessionTokenManager.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션이 수락되었습니다!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션 수락에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }
}

 */