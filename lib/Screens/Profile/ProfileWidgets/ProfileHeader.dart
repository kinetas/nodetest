
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../UserInfo/UserInfo_all.dart';
import '../../../UserInfo/UserInfo_MissionCount.dart';
import '../../Loading.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late Future<Map<String, dynamic>?> _userInfoFuture;
  late Future<MissionCounts> _missionCountsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  void _fetchAll() {
    _userInfoFuture = UserInfoAll().fetchUserInfo();
    _missionCountsFuture = UserInfoMissionCount().fetchMissionCounts();
  }

  void _refreshProfile() {
    setState(() {
      _fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userInfoFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Loading(),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                '프로필 정보를 불러올 수 없습니다.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final userInfo = userSnapshot.data!;
        final userId = userInfo['u_id'] ?? '';
        final profileImgBuffer = userInfo['profile_image'];

        Widget profileImgWidget;
        if (profileImgBuffer != null && profileImgBuffer['data'] != null) {
          final List<int> imgBytes = List<int>.from(profileImgBuffer['data']);
          profileImgWidget = GestureDetector(
            onTap: _refreshProfile,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              backgroundImage: MemoryImage(Uint8List.fromList(imgBytes)),
            ),
          );
        } else {
          profileImgWidget = GestureDetector(
            onTap: _refreshProfile,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          );
        }

        // 미션 카운트 값도 FutureBuilder로 묶어서 같이 보여주기
        return FutureBuilder<MissionCounts>(
          future: _missionCountsFuture,
          builder: (context, missionSnapshot) {
            if (missionSnapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Loading(),
              );
            }

            if (missionSnapshot.hasError || !missionSnapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    '미션 정보를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final missionCounts = missionSnapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '완료한 미션 ${missionCounts.successCount}',
                            style: const TextStyle(color: Colors.lightBlue),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '실패한 미션 ${missionCounts.failCount}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '생성한 미션 ${missionCounts.createMissionCount}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '진행중 미션 ${missionCounts.assignedMissionCount}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                profileImgWidget,
                const SizedBox(height: 12),
                Text(
                  userId,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
