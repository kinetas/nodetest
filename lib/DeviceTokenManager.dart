import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceTokenManager {
  static final DeviceTokenManager _instance = DeviceTokenManager._internal();
  String? _deviceToken;

  factory DeviceTokenManager() {
    return _instance;
  }

  DeviceTokenManager._internal();

  /// 디바이스 토큰 가져오기
  Future<String?> getDeviceToken() async {
    if (_deviceToken != null) {
      print("[DEBUG] Returning cached device token: $_deviceToken");
      return _deviceToken;
    }

    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      _deviceToken = await messaging.getToken();
      print("[DEBUG] Fetched new device token: $_deviceToken");
      return _deviceToken;
    } catch (e) {
      print("[ERROR] Failed to get device token: $e");
      return null;
    }
  }

  /// 디바이스 토큰 초기화 (로그아웃 시 사용 가능)
  void clearToken() {
    print("[DEBUG] Clearing device token.");
    _deviceToken = null;
  }

  /// 디바이스 토큰 상태 확인
  void debugTokenStatus() {
    if (_deviceToken == null) {
      print("[DEBUG] Device token is null.");
    } else {
      print("[DEBUG] Current device token: $_deviceToken");
    }
  }
}