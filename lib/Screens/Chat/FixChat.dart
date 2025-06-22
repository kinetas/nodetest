import 'package:flutter/material.dart';
import 'dart:convert';
import '../../SessionTokenManager.dart';

class FixChat {
  static void show(
      BuildContext context, {
        required String u2Id,
        required String rType,
        void Function()? onUpdated,
      }) {
    final nameCtrl = TextEditingController();
    bool isEditing = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('채팅방 관리'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('상대 ID: $u2Id'),
                  SizedBox(height: 8),
                  Text('채팅방 타입: $rType'),
                  if (isEditing) ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: '새로운 채팅방 이름',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!isEditing) {
                      setState(() => isEditing = true);
                    } else {
                      final newName = nameCtrl.text.trim();
                      if (newName.isEmpty) return;

                      final url = 'http://13.125.65.151:3000/nodetest/api/rooms/update';
                      final body = json.encode({
                        'u2_id': u2Id,
                        'r_type': rType,
                        'newRoomName': newName,
                      });

                      SessionTokenManager.put(url, body: body).then((resp) {
                        Navigator.pop(context);
                        final msg = json.decode(resp.body)['message'] ?? '응답 없음';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(resp.statusCode == 200 ? '이름이 변경되었습니다' : '실패: $msg')),
                        );
                        if (resp.statusCode == 200 && onUpdated != null) onUpdated();
                      });
                    }
                  },
                  child: Text(isEditing ? '확인' : '이름 수정', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('정말 삭제하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('삭제', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    final url = 'http://13.125.65.151:3000/nodetest/api/rooms/$u2Id/$rType';
                    final resp = await SessionTokenManager.delete(url, body: json.encode({
                      'u2_id': u2Id,
                      'r_type': rType,
                    }));

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp.statusCode == 200 ? '방이 삭제되었습니다.' : '삭제 실패: ${resp.statusCode}')),
                    );
                    if (resp.statusCode == 200 && onUpdated != null) {
                      onUpdated();
                    }
                  },
                  child: Text('삭제', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}