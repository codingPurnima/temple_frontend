import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class AuthService {
  static String? _accessToken;
  static String? _refreshToken;

  Future<String?>? _refreshFuture;

  final storage = const FlutterSecureStorage();

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;

  static bool get isLoggedIn => _accessToken != null;

  Future<void> loadTokens() async {
    _accessToken = await storage.read(key: "access_token");
    _refreshToken = await storage.read(key: "refresh_token");
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": email, "password": password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await storage.write(key: "access_token", value: data["access_token"]);
      await storage.write(key: "refresh_token", value: data["refresh_token"]);

      _accessToken = data["access_token"];
      _refreshToken = data["refresh_token"];

      return {"success": true, "data": data};
    } else {
      return {"success": false, "error": response.body};
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: "access_token");
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refresh_token");
  }

  Future<String?> refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _doRefresh();
    return _refreshFuture;
  }

  Future<String?> _doRefresh() async {
    // use memory first
    try{
      String? refreshToken = _refreshToken;

      refreshToken ??= await storage.read(key: "refresh_token");

      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse("$baseUrl/auth/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh_token": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data["access_token"];
        final newRefreshToken = data["refresh_token"];

        await storage.write(key: "access_token", value: newAccessToken);
        await storage.write(key: "refresh_token", value: newRefreshToken);

        // update memory
        _accessToken = newAccessToken;
        _refreshToken = newRefreshToken;

        return newAccessToken;
      }   
      return null;
    } finally {
        _refreshFuture=null;
      }
  }

  Future<void> logout() async {
    final token = _accessToken;
    if (token != null) {
      await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {"Authorization": "Bearer $token"},
      );
    }

    await storage.deleteAll();
    _accessToken = null;
    _refreshToken = null;
  }
}
