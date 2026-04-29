import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();
  Future<Map<String, dynamic>?> getDashboard() async {
    final response = await _apiClient.get("$baseUrl/dashboard/");

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }
}
