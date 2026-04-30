import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    String url = "$baseUrl/auth/me";

    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("ERROR: ${response.statusCode} ${response.body}");
      return {};
    }
  }
}
