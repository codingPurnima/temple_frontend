import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:app/global/global.dart';
import 'package:app/screens/common/login_screen.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${token?.trim()}",
    };
  }

  Future<http.Response> get(String url) async {
    String? token = await _authService.getAccessToken();
    if (token != null && _isTokenExpired(token)) {
      token = await _authService.refreshAccessToken();
    }

    var response = await http.get(Uri.parse(url), headers: _headers(token));

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.get(Uri.parse(url), headers: _headers(newToken));
      } else {
        await _authService.logout();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
        throw Exception("SESSION_EXPIRED");
      }
    }
    return response;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch / 1000;

      return now >= exp;
    } catch (e) {
      return true;
    }
  }

  Future<http.Response> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    String? token = await _authService.getAccessToken();
    if (token != null && _isTokenExpired(token)) {
      token = await _authService.refreshAccessToken();
    }

    var response = await http.post(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.post(
          Uri.parse(url),
          headers: _headers(newToken),
          body: jsonEncode(body),
        );
      } else {
        await _authService.logout();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
        throw Exception("SESSION_EXPIRED");
      }
    }

    return response;
  }

  Future<http.Response> patchRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    String? token = await _authService.getAccessToken();

    if (token != null && _isTokenExpired(token)) {
      token = await _authService.refreshAccessToken();
    }

    var response = await http.patch(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.patch(
          Uri.parse(url),
          headers: _headers(newToken),
          body: jsonEncode(body),
        );
      } else {
        await _authService.logout();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
        throw Exception("SESSION_EXPIRED");
      }
    }

    return response;
  }

  Future<http.Response> delete(String url) async{
     String? token = await _authService.getAccessToken();

    if (token != null && _isTokenExpired(token)) {
      token = await _authService.refreshAccessToken();
    }

    var response = await http.delete(
      Uri.parse(url),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.delete(
          Uri.parse(url),
          headers: _headers(newToken),
        );
      } else {
        await _authService.logout();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
        throw Exception("SESSION_EXPIRED");
      }
    }

    return response;
  }
}
