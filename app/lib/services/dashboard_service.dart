import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> getDashboard() async {
    final rawToken = await _authService.getAccessToken();
    final token = rawToken?.trim();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/"),
      headers: {
        "Authorization": "Bearer ${token.trim()}",
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200
        ? jsonDecode(response.body)
        : null;
  }
}