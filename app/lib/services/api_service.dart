import 'dart:convert';

import 'package:app/core/constants.dart';
import 'package:app/widgets/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'package:app/global/global.dart';
import 'package:app/screens/common/login_screen.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }

    return headers;
  }

  Future<String?> _getToken() async {
    return await _authService.getAccessToken();
  }

  Future<void> _handleUnauthorized() async {
    await _authService.logout();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<http.Response> get(String url) async {
    final token = await _getToken();

    var response = await http.get(
      Uri.parse(url),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }

  Future<http.Response> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();

    var response = await http.post(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }

  Future<http.Response> patchRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();

    var response = await http.patch(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }

  Future<http.Response> delete(String url) async {
    final token = await _getToken();

    var response = await http.delete(
      Uri.parse(url),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }

  static Future<List<User>> getUsers(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/users"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch users");
    }
  }

  static Future<void> makeAdmin(
    int userId,
    String token,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/make-admin/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to promote user");
    }
  }
}