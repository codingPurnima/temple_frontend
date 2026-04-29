import 'dart:convert';

import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> get(String url) async {
    String? token = AuthService.accessToken;

    var response = await http.get(
      Uri.parse(url),
      headers: _headers(token),
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.get(
          Uri.parse(url),
          headers: _headers(newToken),
        );
      }
    }
    return response;
  }

  Future<http.Response> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    String? token = AuthService.accessToken;

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
      }
    }

    return response;
  }

  Future<http.Response> patchRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    String? token = AuthService.accessToken;

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
      }
    }

    return response;
  }
}
