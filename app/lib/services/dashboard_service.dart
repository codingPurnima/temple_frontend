import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();
  Future<Map<String, dynamic>?> getDashboard() async {
    final response = await _apiClient.get("$baseUrl/dashboard/");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }

  }

  Future<Map<String, dynamic>> joinEvent(int eventId) async {
    final response = await _apiClient.postRequest(
      "$baseUrl/events/$eventId/join",
      {},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed");
    }
  }
  
  Future<void> leaveEvent(int eventId) async {
  final response = await _apiClient.delete(
    "$baseUrl/events/$eventId/leave",
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to leave event");
  }
}
}

