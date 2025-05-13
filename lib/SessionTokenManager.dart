import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class SessionTokenManager {
  static String? _token;

  static Future<void> saveToken(String token) async {
    _token = token;
    // TODO: SharedPreferences 저장 코드
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    // TODO: SharedPreferences에서 가져오기
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<http.Response> get(String url) async {
    final token = await getToken();
    print('📤 [GET] $url with Bearer $token');
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [POST] $url');
    print('📤 Headers: $allHeaders');
    print('📤 Body: $body');
    return await http.post(Uri.parse(url), headers: allHeaders, body: body);
  }

  static Future<http.Response> delete(String url, {Map<String, String>? headers, dynamic body}) async {
    final token = await getToken();
    final allHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    print('📤 [DELETE] $url');
    print('📤 Headers: $allHeaders');
    print('📤 Body: $body');
    return await http.delete(Uri.parse(url), headers: allHeaders, body: body);
  }
}