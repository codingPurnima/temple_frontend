import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class LyricsService {
  final ApiClient _apiClient = ApiClient();

  Future<List> getLyrics({String? search}) async {
    String url = "$baseUrl/lyrics/get";

    if (search != null && search.isNotEmpty) {
      url += "?search=$search";
    }

    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLyricById(int id) async {
    final response = await _apiClient.get("$baseUrl/lyrics/by-id/$id");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return null;
    }
  }
}
