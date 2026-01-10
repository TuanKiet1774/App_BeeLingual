import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import '../connect_api/url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../view/account/log_in_page.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$urlAPI/api/login');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        print(data);
        if (accessToken != null && refreshToken != null) {
          await saveSession(accessToken: accessToken, refreshToken: refreshToken);
          return data;
        }
      }
      print("Login thất bại: ${res.body}");
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^\S+$');
    return usernameRegex.hasMatch(username);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,24}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Future<Map<String, dynamic>?> signUp({
    required String username,
    required String email,
    required String fullname,
    required String password,
    required String role,
    required String level
  }) async {
    final url = Uri.parse('$urlAPI/api/register');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'fullname': fullname,
          'password': password,
          'role': role,
          'level': level
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        return {
          "error": true,
          "message": jsonDecode(res.body)["message"] ?? "Lỗi không xác định"
        };
      }
    } catch (e) {
      return {"error": true, "message": "Không thể kết nối server!"};
    }
  }

  SupabaseClient get supabase => Supabase.instance.client;
  Future<AuthResponse> signUpSupabase({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    return res;
  }


  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    if (refreshToken.isNotEmpty) {
      await prefs.setString('refreshToken', refreshToken);
    }
    print("Đã lưu Session mới: $accessToken");
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) return false;

    final url = Uri.parse('$urlAPI/api/refresh-token');
    try {
      print("Đang thử Refresh Token...");
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newAccess = data['token'] ?? data['accessToken']; // Check cả 2 key

        if (newAccess != null) {
          await prefs.setString('accessToken', newAccess);
          print("Refresh Token thành công!");
          return true;
        }
      }
    } catch (e) {
      print("Lỗi Refresh token: $e");
    }
    return false;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PageLogIn()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    return accessToken != null && refreshToken != null;
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final loggedIn = await isLoggedIn();
    if (!loggedIn) {
      await logout(context);
    }
  }
}
