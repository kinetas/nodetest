
import 'package:firebase_messaging/firebase_messaging.dart';


class DeviceTokenManager {
  static final DeviceTokenManager _instance = DeviceTokenManager._internal();
  String? _deviceToken;

  factory DeviceTokenManager() {
    return _instance;
  }

  DeviceTokenManager._internal();

  /// 디바이스 토큰 가져오기 (null 허용)
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


  /// 로그아웃 시 초기화
  void clearToken() {
    print("[DEBUG] Clearing device token.");
    _deviceToken = null;
  }



  /// 디버그 용도
  void debugTokenStatus() {
    if (_deviceToken == null) {
      print("[DEBUG] Device token is null.");
    } else {
      print("[DEBUG] Current device token: $_deviceToken");
    }
  }
}